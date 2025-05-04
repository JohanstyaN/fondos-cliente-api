from fastapi import FastAPI
from app.routers import funds

app = FastAPI()
app.include_router(funds.router)
