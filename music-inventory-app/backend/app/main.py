from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from starlette.middleware.cors import CORSMiddleware

from .crud import (
    get_inventory, search_inventory,
    create_record, update_record, delete_record
)
from .auth import get_current_admin

app = FastAPI(
    title="Music Inventory API",
    description="CRUD for music inventory, backed by the original JSON file.",
)

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
    allow_origins=["http://localhost:5173"],  # Vite dev server
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
def modify_record(serial: int, record: dict, admin: str = Depends(get_current_admin)):
    return update_record(serial, record)

@app.delete("/inventory/{serial}")
def remove_record(serial: int, admin: str = Depends(get_current_admin)):
    delete_record(serial)
    return {"detail": "Deleted"}

# ---------- Admin auth ----------
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

@app.post("/token")
def login(form_data: OAuth2PasswordRequestForm = Depends()):
    # Very simple – replace with a proper DB in prod
    if form_data.username == "admin" and form_data.password == "supersecret":
        return {"access_token": "demo-token", "token_type": "bearer"}
    raise HTTPException(status_code=400, detail="Incorrect credentials")

