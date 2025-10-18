from fastapi import FastAPI
from pydantic import BaseModel, Field
from transformers import pipeline
import re

# Create pipeline
generator = pipeline("text-generation", model="distilgpt2")
app = FastAPI()

class Prompt(BaseModel):
    prompt: str
    max_new_tokens: int = Field(256, ge=1, le=32768, description="Max tokens to generate")

@app.post("/generate")
def generate_text(input: Prompt):
    result = generator(input.prompt, max_new_tokens=input.max_new_tokens)
    text = result[0]['generated_text'].rstrip()
    text = re.sub(r"\n{2,}", "\n", text)
    text = re.sub(r"[^\w\s,.!?]+$", "", text)
    text = re.sub(r"[^\x20-\x7E\n]+", "", text)
    return {"completion": text}
