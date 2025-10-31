from fastapi import FastAPI, Depends, HTTPException, status, Request
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from starlette.middleware.cors import CORSMiddleware
from pathlib import Path
import logging

from .crud import (
    get_inventory, search_inventory,
    create_record, update_record, delete_record
)
from .auth import get_current_admin, create_token

app = FastAPI(
    title="Music Inventory API",
    description="CRUD for music inventory, backed by the original JSON file.",
)

# Configure logging for external access
log_dir = Path(__file__).parent.parent / 'logs'
log_dir.mkdir(exist_ok=True)
log_file = log_dir / 'external_access.log'

external_logger = logging.getLogger('external_access')
external_logger.setLevel(logging.INFO)
file_handler = logging.FileHandler(log_file, encoding='utf-8')
file_handler.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
file_handler.setFormatter(formatter)
external_logger.addHandler(file_handler)

# Load credentials from .secrets file
def load_credentials():
    """Load admin credentials from .secrets file."""
    secrets_file = Path(__file__).parent.parent / '.secrets'
    credentials = {}
    
    if secrets_file.exists():
        with open(secrets_file, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#'):
                    if ':' in line:
                        username, password = line.split(':', 1)
                        credentials[username.strip()] = password.strip()
    else:
        # Fallback to default credentials if file doesn't exist
        credentials['admin'] = 'supersecret'
    
    return credentials

ADMIN_CREDENTIALS = load_credentials()

# Middleware to log external IP access
@app.middleware("http")
async def log_external_access(request: Request, call_next):
    # Get client IP
    client_ip = request.client.host if request.client else "unknown"
    
    # Check for forwarded IP (if behind a proxy)
    forwarded = request.headers.get("X-Forwarded-For")
    if forwarded:
        client_ip = forwarded.split(",")[0].strip()
    
    # Log if not from localhost
    if client_ip not in ["127.0.0.1", "::1", "localhost", "unknown"]:
        external_logger.info(
            f"External access from {client_ip} - {request.method} {request.url.path}"
        )
    
    response = await call_next(request)
    return response

@app.get("/")
def read_root():
    """API root showing version and status."""
    return {
        "app": "Music Inventory API",
        "status": "running",
        "version": "1.0.0"
    }

@app.get("/health")
def health_check():
    """Health check endpoint."""
    return {"status": "healthy"}

# Allow frontend origin
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",  # Vite dev server
        "http://localhost:8080",  # nginx-proxy
        "http://localhost:9000"   # public frontend
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/inventory", response_model=list)
def read_inventory(search: str | None = None):
    """Return all records, optionally filtered by search string."""
    return search_inventory(search) if search else get_inventory()

@app.post("/inventory", status_code=status.HTTP_201_CREATED)
def add_record(record: dict, admin: str = Depends(get_current_admin)):
    return create_record(record)

@app.put("/inventory/{serial}")
def modify_record(serial: str, record: dict, admin: str = Depends(get_current_admin)):
    return update_record(serial, record)

@app.delete("/inventory/{serial}")
def remove_record(serial: str, admin: str = Depends(get_current_admin)):
    delete_record(serial)
    return {"detail": "Deleted"}

# ---------- Admin auth ----------
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

@app.post("/token")
def login(form_data: OAuth2PasswordRequestForm = Depends(), request: Request = None):
    username = form_data.username
    password = form_data.password
    
    # Get client IP address
    client_ip = "unknown"
    if request:
        client_ip = request.client.host if request.client else "unknown"
        # Check for forwarded IP (if behind a proxy)
        forwarded = request.headers.get("X-Forwarded-For")
        if forwarded:
            client_ip = forwarded.split(",")[0].strip()
    
    if username in ADMIN_CREDENTIALS and ADMIN_CREDENTIALS[username] == password:
        external_logger.info("Successful login - Username: %s - IP: %s", username, client_ip)
        # Create user-specific token
        token = create_token(username)
        return {"access_token": token, "token_type": "bearer"}
    
    # Log unauthorized access attempt
    external_logger.warning("UNAUTHORIZED login attempt - Username: %s - IP: %s", username, client_ip)
    raise HTTPException(status_code=400, detail="Invalid credentials")


