from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv
import google.generativeai as genai
import os
import json

load_dotenv()

# Configure Gemini (using the model that worked for you)
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
model = genai.GenerativeModel("gemini-3.6-flash")

app = FastAPI(title="Perplexity Clone API")

# Allow Flutter to talk to this backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ChatRequest(BaseModel):
    query: str

class ChatResponse(BaseModel):
    answer: str

class QuizRequest(BaseModel):
    text: str

@app.get("/")
def root():
    return {"message": "Perplexity Clone Backend is running"}

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    try:
        prompt = f"""
        You are a helpful AI assistant similar to Perplexity.
        Give a clear, well-structured, and informative answer.

        Question: {request.query}
        """
        response = model.generate_content(prompt)
        return ChatResponse(answer=response.text)
    except Exception as e:
        return ChatResponse(answer=f"Error: {str(e)}")

@app.post("/generate-quiz")
async def generate_quiz(request: QuizRequest):
    try:
        prompt = f"""
        Based on the following text, create exactly 3 multiple-choice questions.
        Each question must have exactly 4 options.
        One option must be correct.
        
        Return ONLY valid JSON in this exact format (no markdown, no extra text):

        {{
          "questions": [
            {{
              "question": "Question text here?",
              "options": ["Option A", "Option B", "Option C", "Option D"],
              "correctIndex": 0
            }},
            {{
              "question": "Question text here?",
              "options": ["Option A", "Option B", "Option C", "Option D"],
              "correctIndex": 1
            }},
            {{
              "question": "Question text here?",
              "options": ["Option A", "Option B", "Option C", "Option D"],
              "correctIndex": 2
            }}
          ]
        }}

        Text:
        {request.text}
        """

        response = model.generate_content(prompt)
        raw = response.text.strip()

        # Clean possible markdown code blocks
        if raw.startswith("```"):
            raw = raw.strip("`").replace("json", "", 1).strip()

        data = json.loads(raw)
        return data

    except Exception as e:
        return {
            "questions": [],
            "error": str(e)
        }