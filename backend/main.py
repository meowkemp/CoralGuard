import os
import io
import json
import re
from typing import Dict, Any, Optional, List

from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
from PIL import Image
from dotenv import load_dotenv

load_dotenv()

# -----------------------------
# Optional: Google Cloud Vision
# -----------------------------
try:
    from google.cloud import vision
except Exception:
    vision = None  # allows running without google-cloud-vision installed

# -----------------------------
# Optional: Gemini (Google AI Studio)
# -----------------------------
try:
    from google import genai
except Exception:
    genai = None  # allows running without the library


app = FastAPI(title="CoralGuard Backend (Vision + Digital Twin + Gemini)")

# -----------------------------
# CORS (dev-friendly)
# -----------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,  # must be False when allow_origins=["*"]
    allow_methods=["*"],
    allow_headers=["*"],
)

# -----------------------------
# Global Gemini client (created once)
# -----------------------------
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-2.5-flash")
GEMINI_CLIENT = None

_api_key = os.getenv("GEMINI_API_KEY")
if _api_key and genai is not None:
    try:
        GEMINI_CLIENT = genai.Client(api_key=_api_key)
    except Exception:
        GEMINI_CLIENT = None


# -----------------------------
# Utils
# -----------------------------
def clamp(x: float, lo: float, hi: float) -> float:
    return max(lo, min(hi, x))


def is_supported_image_bytes(image_bytes: bytes) -> bool:
    """Basic magic header check for JPG / PNG / WEBP."""
    if not image_bytes or len(image_bytes) < 12:
        return False
    is_jpg = image_bytes.startswith(b"\xff\xd8\xff")
    is_png = image_bytes.startswith(b"\x89PNG\r\n\x1a\n")
    is_webp = image_bytes.startswith(b"RIFF") and b"WEBP" in image_bytes[:16]
    return is_jpg or is_png or is_webp


def extract_json_object(text: str) -> Optional[dict]:
    """
    Gemini sometimes returns extra text or fenced code blocks.
    This extracts the first JSON object found and parses it.
    """
    if not text:
        return None

    t = text.strip()

    # strip ```json fences if any
    t = re.sub(r"^```json\s*", "", t)
    t = re.sub(r"^```\s*", "", t)
    t = re.sub(r"\s*```$", "", t)

    start = t.find("{")
    end = t.rfind("}")
    if start == -1 or end == -1 or end <= start:
        return None

    candidate = t[start : end + 1]
    try:
        return json.loads(candidate)
    except Exception:
        return None


# -----------------------------
# Local image feature extraction (Pillow)
# -----------------------------
def extract_features_from_image(image_bytes: bytes) -> Dict[str, float]:
    """
    Lightweight proxies derived from overall color distribution.
    This is NOT a classifier — it's a simple "visual stress" proxy.

    Outputs:
    - coral_conf: simulated confidence (0..1)
    - bleaching_proxy: higher when image is bright + low saturation (0..1)
    - algae_proxy: higher when green is dominant (0..1)
    - brightness: 0..1
    - saturation: 0..1
    - mean_rgb: 0..1 values
    """
    try:
        img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    except Exception as e:
        raise RuntimeError(f"Failed to decode image: {e}")

    img = img.resize((128, 128))
    pixels = list(img.getdata())
    n = len(pixels) or 1

    r = sum(p[0] for p in pixels) / (255.0 * n)
    g = sum(p[1] for p in pixels) / (255.0 * n)
    b = sum(p[2] for p in pixels) / (255.0 * n)

    brightness = (r + g + b) / 3.0
    maxc, minc = max(r, g, b), min(r, g, b)
    saturation = 0.0 if maxc == 0 else (maxc - minc) / maxc

    bleaching_proxy = clamp((brightness * (1.0 - saturation) - 0.2) / 0.6, 0.0, 1.0)
    algae_proxy = clamp((g - (r + b) / 2.0 + 0.1) / 0.6, 0.0, 1.0)
    coral_conf = clamp(1.0 - algae_proxy * 0.7, 0.0, 1.0)

    return {
        "coral_conf": float(round(coral_conf, 3)),
        "bleaching_proxy": float(round(bleaching_proxy, 3)),
        "algae_proxy": float(round(algae_proxy, 3)),
        "brightness": float(round(brightness, 3)),
        "saturation": float(round(saturation, 3)),
        "mean_r": float(round(r, 3)),
        "mean_g": float(round(g, 3)),
        "mean_b": float(round(b, 3)),
    }


# -----------------------------
# Google Vision feature extraction (Cloud Vision API)
# -----------------------------
def extract_features_with_vision(image_bytes: bytes) -> Dict[str, Any]:
    """
    Uses Google Cloud Vision API to extract:
    - dominant colors (image properties)
    - labels (label detection)

    Also derives brightness/saturation proxies from dominant colors when available.
    Falls back to local extractor if Vision isn't available or credentials fail.
    """
    if vision is None:
        local = extract_features_from_image(image_bytes)
        return {"vision": None, **local}

    # If client init fails (missing creds), fallback to local
    try:
        client = vision.ImageAnnotatorClient()
        image = vision.Image(content=image_bytes)
    except Exception:
        local = extract_features_from_image(image_bytes)
        return {"vision": None, **local}

    dominant_colors: List[Dict[str, Any]] = []
    try:
        props = client.image_properties(image=image).image_properties_annotation
        if props and props.dominant_colors and props.dominant_colors.colors:
            for c in props.dominant_colors.colors[:5]:
                dominant_colors.append(
                    {
                        "r": int(c.color.red),
                        "g": int(c.color.green),
                        "b": int(c.color.blue),
                        "score": float(c.score),
                        "pixel_fraction": float(c.pixel_fraction),
                    }
                )
    except Exception:
        dominant_colors = []

    labels: List[Dict[str, Any]] = []
    try:
        labels_resp = client.label_detection(image=image, max_results=10)
        for l in labels_resp.label_annotations or []:
            labels.append(
                {
                    "description": l.description,
                    "score": float(l.score),
                    "topicality": float(getattr(l, "topicality", 0.0)),
                }
            )
    except Exception:
        labels = []

    if not dominant_colors:
        local = extract_features_from_image(image_bytes)
        return {
            "vision": {"dominant_colors": [], "labels": labels},
            **local,
        }

    wsum = sum(c["pixel_fraction"] for c in dominant_colors) or 1.0
    mr = sum(c["r"] * c["pixel_fraction"] for c in dominant_colors) / wsum / 255.0
    mg = sum(c["g"] * c["pixel_fraction"] for c in dominant_colors) / wsum / 255.0
    mb = sum(c["b"] * c["pixel_fraction"] for c in dominant_colors) / wsum / 255.0

    brightness = (mr + mg + mb) / 3.0
    maxc, minc = max(mr, mg, mb), min(mr, mg, mb)
    saturation = 0.0 if maxc == 0 else (maxc - minc) / maxc

    bleaching_proxy = clamp((brightness * (1.0 - saturation) - 0.2) / 0.6, 0.0, 1.0)
    algae_proxy = clamp((mg - (mr + mb) / 2.0 + 0.1) / 0.6, 0.0, 1.0)
    coral_conf = clamp(1.0 - algae_proxy * 0.7, 0.0, 1.0)

    return {
        "vision": {"dominant_colors": dominant_colors, "labels": labels},
        "coral_conf": float(round(coral_conf, 3)),
        "bleaching_proxy": float(round(bleaching_proxy, 3)),
        "algae_proxy": float(round(algae_proxy, 3)),
        "brightness": float(round(brightness, 3)),
        "saturation": float(round(saturation, 3)),
        "mean_r": float(round(mr, 3)),
        "mean_g": float(round(mg, 3)),
        "mean_b": float(round(mb, 3)),
    }


# -----------------------------
# Digital twin (deterministic)
# -----------------------------
def run_digital_twin(temp_c: float, bleaching_proxy: float, algae_proxy: float) -> Dict[str, Any]:
    temp_stress = clamp((temp_c - 28.0) / 4.0, 0.0, 1.0)  # 28->0, 32->1
    visual_stress = clamp(0.6 * bleaching_proxy + 0.4 * algae_proxy, 0.0, 1.0)
    stress = clamp(0.65 * temp_stress + 0.35 * visual_stress, 0.0, 1.0)

    base_health = 100.0 * (1.0 - visual_stress)
    health_now = clamp(base_health - 35.0 * temp_stress, 0.0, 100.0)

    forecast = [{"day": 0, "health": round(health_now, 1)}]
    h = health_now
    for d in range(1, 15):
        damage = 6.0 * stress
        recovery = 2.0 * (1.0 - stress)
        h = clamp(h - damage + recovery, 0.0, 100.0)
        forecast.append({"day": d, "health": round(h, 1)})

    health_day14 = forecast[-1]["health"]
    drop_14 = float(health_now) - float(health_day14)

    if stress >= 0.7 or drop_14 >= 30:
        risk_level = "HIGH"
    elif stress >= 0.4 or drop_14 >= 15:
        risk_level = "MEDIUM"
    else:
        risk_level = "LOW"

    return {
        "health_now": round(health_now, 1),
        "stress": round(stress, 3),
        "risk_level": risk_level,
        "drivers": {
            "temp_stress": round(temp_stress, 3),
            "visual_stress": round(visual_stress, 3),
            "bleaching_proxy": round(float(bleaching_proxy), 3),
            "algae_proxy": round(float(algae_proxy), 3),
        },
        "forecast_14d": forecast,
        "health_day14": health_day14,
    }


# -----------------------------
# Gemini (optional)
# -----------------------------
def gemini_explain(twin: Dict[str, Any], temp_c: float) -> Dict[str, Any]:
    """
    Returns AI recommendations if GEMINI_API_KEY is set.
    Otherwise returns a clean fallback for demo.
    """

    def fallback() -> Dict[str, Any]:
        risk = twin.get("risk_level", "LOW")
        stress = float(twin.get("stress", 0.0))

        if risk == "HIGH" or stress >= 0.7:
            recs = [
                {"title": "Trigger bleaching alert", "why": "High modeled stress suggests near-term degradation risk.", "priority": "HIGH"},
                {"title": "Reduce local disturbances", "why": "Lowering physical stress improves resilience during heat events.", "priority": "HIGH"},
                {"title": "Increase monitoring frequency", "why": "More frequent checks help detect rapid health decline early.", "priority": "MEDIUM"},
            ]
        elif risk == "MEDIUM" or stress >= 0.4:
            recs = [
                {"title": "Monitor reef weekly", "why": "Moderate stress can worsen quickly with sustained heat.", "priority": "MEDIUM"},
                {"title": "Limit human activity nearby", "why": "Reducing contact damage improves recovery probability.", "priority": "MEDIUM"},
                {"title": "Track temperature trends", "why": "Temperature spikes are the strongest bleaching driver.", "priority": "HIGH"},
            ]
        else:
            recs = [
                {"title": "Maintain routine monitoring", "why": "Low stress now, but early detection remains important.", "priority": "LOW"},
                {"title": "Record baseline health photos", "why": "Baselines help quantify future changes objectively.", "priority": "LOW"},
                {"title": "Keep water conditions stable", "why": "Stable conditions reduce the likelihood of stress escalation.", "priority": "LOW"},
            ]

        return {"summary": f"Digital twin indicates {risk} bleaching risk at {temp_c:.1f}°C.", "recommendations": recs}

    if GEMINI_CLIENT is None:
        return fallback()

    prompt = f"""
Return VALID JSON only. No markdown.

Given:
temp_c={temp_c}
stress={twin["stress"]}
risk_level={twin["risk_level"]}
health_now={twin["health_now"]}
health_day14={twin["health_day14"]}
drivers={json.dumps(twin["drivers"], ensure_ascii=False)}

Return schema:
{{
  "summary":"string",
  "recommendations":[
    {{"title":"string","why":"string","priority":"HIGH|MEDIUM|LOW"}}
  ]
}}
""".strip()

    try:
        resp = GEMINI_CLIENT.models.generate_content(
            model=GEMINI_MODEL,
            contents=prompt,
        )
        parsed = extract_json_object((resp.text or "").strip())
        if parsed and parsed.get("recommendations"):
            return parsed
        return fallback()
    except Exception:
        return fallback()


# -----------------------------
# Endpoint: analyze
# -----------------------------
@app.post("/analyze")
async def analyze(
    temp_c: float = Form(...),
    file: UploadFile = File(...),
):
    if temp_c < 0 or temp_c > 50:
        raise HTTPException(status_code=400, detail="temp_c out of range")

    image_bytes = await file.read()

    if not is_supported_image_bytes(image_bytes):
        raise HTTPException(status_code=400, detail="Uploaded file is not a valid JPG/PNG/WEBP image.")

    use_vision = os.getenv("USE_VISION", "1") == "1"

    try:
        feats: Dict[str, Any] = extract_features_with_vision(image_bytes) if use_vision else {"vision": None, **extract_features_from_image(image_bytes)}

        twin = run_digital_twin(
            temp_c=temp_c,
            bleaching_proxy=float(feats["bleaching_proxy"]),
            algae_proxy=float(feats["algae_proxy"]),
        )

        ai = gemini_explain(twin, temp_c=temp_c)

        return {
            "input": {"temp_c": temp_c},
            "image_features": feats,
            **twin,
            "ai_analysis": ai,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/favicon.ico")
def favicon():
    return Response(status_code=204)