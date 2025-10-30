from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
import base64
import json

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

def create_token(username: str) -> str:
    """Create a simple token encoding the username."""
    token_data = {"username": username}
    token_str = json.dumps(token_data)
    return base64.b64encode(token_str.encode()).decode()

def decode_token(token: str) -> dict:
    """Decode the token to get user information."""
    try:
        token_str = base64.b64decode(token.encode()).decode()
        return json.loads(token_str)
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid token")

def get_current_admin(token: str = Depends(oauth2_scheme)):
    """Verify token and return username. Only allow admin or toddb."""
    token_data = decode_token(token)
    username = token_data.get("username")
    
    # Only allow admin or toddb users
    if username not in ["admin", "toddb"]:
        raise HTTPException(
            status_code=403, 
            detail="Only admin or toddb users can make changes"
        )
    
    return username

