from fastapi import FastAPI
from .api.v1.router import router as v1_router

app = FastAPI(title="Template")

@app.get(/api/health, tags=['Health'])
def health_check():
    return {"status": "ok"}

app.include_router(v1_router, prefix="/api/v1")
