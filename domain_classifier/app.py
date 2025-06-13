from fastapi import FastAPI
from pydantic import BaseModel
from semantic_model import SemanticDomainClassifier

app = FastAPI()

classifier = SemanticDomainClassifier()

class Query(BaseModel):
    text: str

@app.post("/predict")
def predict(query: Query):
    result = classifier.predict(query.text)
    return {"domain": result}

@app.post("/predict_top_k")
def predict_top_k(query: Query, k: int = 3):
    top_results = classifier.predict_top_k(query.text, k)
    return {
        "query": query.text,
        "top_predictions": [
            {"domain": label, "score": round(score, 4)} for label, score in top_results
        ]
    }
#uvicorn app:app --reload