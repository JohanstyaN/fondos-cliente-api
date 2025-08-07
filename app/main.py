from fastapi import FastAPI, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response, JSONResponse
from fastapi import Request as FastAPIRequest
from starlette.datastructures import State
from app.routers import funds
import logging
import traceback
import time

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler('/tmp/api.log', mode='a')
    ]
)

logger = logging.getLogger("fondos-api")

app = FastAPI()

# Middleware para logging de requests
@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    
    # Log request
    logger.info(f"🔵 REQUEST: {request.method} {request.url}")
    logger.info(f"🔵 Headers: {dict(request.headers)}")
    
    # Read body if it exists
    if request.method in ["POST", "PUT", "PATCH"]:
        body = await request.body()
        if body:
            logger.info(f"🔵 Body: {body.decode('utf-8')}")
        # Important: create a new request with the body for the next middleware
        
        async def receive():
            return {"type": "http.request", "body": body}
        
        request = FastAPIRequest(
            scope=request.scope,
            receive=receive
        )
    
    try:
        response = await call_next(request)
        process_time = time.time() - start_time
        
        logger.info(f"RESPONSE: {response.status_code} - {process_time:.3f}s")
        
        return response
        
    except Exception as e:
        process_time = time.time() - start_time
        logger.error(f"ERROR: {str(e)} - {process_time:.3f}s")
        logger.error(f"Traceback: {traceback.format_exc()}")
        
        return JSONResponse(
            status_code=500,
            content={
                "detail": "Internal server error",
                "error": str(e),
                "timestamp": time.time()
            }
        )

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, especifica los dominios exactos
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Endpoint para manejar CORS preflight requests
@app.options("/{full_path:path}")
async def options_handler(request: Request, full_path: str):
    return Response(
        status_code=200,
        headers={
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type, Authorization",
        }
    )

# Health check endpoint
@app.get("/health")
def health_check():
    return {"status": "healthy", "service": "fondos-api"}

app.include_router(funds.router)
