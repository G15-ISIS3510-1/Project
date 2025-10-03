# app/services/ai_pricing.py
import json, os, re
from typing import Optional
from langchain_core.prompts import ChatPromptTemplate
from langchain_google_genai import ChatGoogleGenerativeAI

class AIPricingService:
    def __init__(self, temperature: float = 0.2, model: Optional[str] = None):
        api_key = os.getenv("GEMINI_API_KEY") or os.getenv("GOOGLE_API_KEY")
        if not api_key:
            raise RuntimeError("Falta GEMINI_API_KEY/GOOGLE_API_KEY")

        self.model_id = model or "gemini-2.5-flash"
        self.llm = ChatGoogleGenerativeAI(
            model=self.model_id,
            google_api_key=api_key,
            temperature=temperature,
            # 👇 fuerza salida JSON pura (sin texto adicional)
            model_kwargs={"response_mime_type": "application/json"},
        )

        # Límite razonable para precios (evita outliers de la LLM)
        self.min_price = 5.0
        self.max_price = 1000.0

    async def suggest(
        self,
        user_vehicles: list[dict],
        form: dict,
        currency: str = "USD",
    ) -> dict:
        prompt = ChatPromptTemplate.from_messages([
            ("system",
             "Eres un modelo de precios de alquiler de autos. "
             "Devuelve ÚNICAMENTE un objeto JSON con las claves:\n"
             "  - \"suggested_price\": número (no string)\n"
             "  - \"reasoning\": string breve (<=180 chars)\n"
             "No incluyas texto fuera del JSON. Sin bloques ``` ni explicaciones."),
            ("user",
             "Histórico del dueño (JSON):\n{history}\n\n"
             "Vehículo nuevo (JSON):\n{form}\n\n"
             "Moneda: {currency}\n"
             "Responde SOLO el JSON pedido.")
        ])

        chain = prompt | self.llm

        try:
            resp = await chain.ainvoke({
                "history": json.dumps(user_vehicles, ensure_ascii=False),
                "form": json.dumps(form, ensure_ascii=False),
                "currency": currency,
            })

            raw = (resp.content or "").strip()

            # Intento 1: JSON puro
            try:
                data = json.loads(raw)
            except json.JSONDecodeError:
                # Intento 2: si vino con ```json ... ``` o algo similar, limpia
                cleaned = raw.strip().removeprefix("```json").removesuffix("```").strip()
                try:
                    data = json.loads(cleaned)
                except Exception:
                    # Intento 3: extraer primer número como precio
                    m = re.search(r"-?\d+(?:\.\d+)?", raw)
                    price = float(m.group(0)) if m else 80.0
                    return {
                        "suggested_price": self._clamp(price),
                        "reasoning": "Fallback parse (no JSON).",
                        "provider": f"gemini:{self.model_id}",
                    }

            price = float(data.get("suggested_price"))
            reasoning = str(data.get("reasoning", ""))[:180]
            return {
                "suggested_price": self._clamp(price),
                "reasoning": reasoning,
                "provider": f"gemini:{self.model_id}",
            }

        except Exception as e:
            return {
                "suggested_price": 80.0,
                "reasoning": f"Fallback (LLM error: {type(e).__name__})",
                "provider": "fallback",
            }

    def _clamp(self, v: float) -> float:
        if v < self.min_price: return self.min_price
        if v > self.max_price: return self.max_price
        return round(v, 2)
