from fastapi import FastAPI, HTTPException, status, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
from typing import Optional, List
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session

# 1. Database Configuration
SQLALCHEMY_DATABASE_URL = "sqlite:///./sql_app.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# 2. Database Models
class UserDB(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    email = Column(String, unique=True, index=True)
    password = Column(String) # Plaintext for demo only, hash in production
    gender = Column(String, nullable=True)
    level = Column(Integer, nullable=True)

Base.metadata.create_all(bind=engine)

# 3. Pydantic Models (Schemas)
class UserCreate(BaseModel):
    name: str
    email: EmailStr
    password: str
    gender: Optional[str] = None
    level: Optional[int] = None

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    gender: Optional[str] = None
    level: Optional[int] = None

    class Config:
        from_attributes = True

class Product(BaseModel):
    id: str
    name: str
    imageUrl: str
    price: float

class Restaurant(BaseModel):
    id: str
    name: str
    address: str
    latitude: float
    longitude: float
    imageUrl: str
    products: List[Product]

# 4. FastAPI App Initialization
app = FastAPI(title="Restaurant API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 5. Mock Data for Restaurants and Products
MOCK_PRODUCTS = [
    Product(id="p1", name="Espresso", imageUrl="https://via.placeholder.com/150", price=2.50),
    Product(id="p2", name="Latte", imageUrl="https://via.placeholder.com/150", price=3.50),
    Product(id="p3", name="Croissant", imageUrl="https://via.placeholder.com/150", price=2.00),
    Product(id="p4", name="Burger", imageUrl="https://via.placeholder.com/150", price=8.50),
    Product(id="p5", name="Fries", imageUrl="https://via.placeholder.com/150", price=3.00),
]

MOCK_RESTAURANTS = [
    Restaurant(
        id="r1", name="Cafe Mocha", address="123 Coffee St", latitude=40.7128, longitude=-74.0060,
        imageUrl="https://via.placeholder.com/300x150", products=[MOCK_PRODUCTS[0], MOCK_PRODUCTS[1], MOCK_PRODUCTS[2]]
    ),
    Restaurant(
        id="r2", name="Burger Joint", address="456 Fast Food Ave", latitude=40.7138, longitude=-74.0070,
        imageUrl="https://via.placeholder.com/300x150", products=[MOCK_PRODUCTS[3], MOCK_PRODUCTS[4]]
    ),
    Restaurant(
        id="r3", name="Downtown Diner", address="789 Downtown Blvd", latitude=40.7118, longitude=-74.0050,
        imageUrl="https://via.placeholder.com/300x150", products=[MOCK_PRODUCTS[0], MOCK_PRODUCTS[3], MOCK_PRODUCTS[4]]
    ),
]

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 6. Endpoints

@app.post("/signup", response_model=UserResponse)
def signup(user: UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(UserDB).filter(UserDB.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    new_user = UserDB(
        name=user.name,
        email=user.email,
        password=user.password,
        gender=user.gender,
        level=user.level
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

@app.post("/login", response_model=UserResponse)
def login(user: UserLogin, db: Session = Depends(get_db)):
    db_user = db.query(UserDB).filter(UserDB.email == user.email).first()
    if not db_user or db_user.password != user.password:
        raise HTTPException(status_code=401, detail="Invalid email or password")
    return db_user

@app.get("/restaurants", response_model=List[Restaurant])
def get_restaurants():
    return MOCK_RESTAURANTS

@app.get("/products/{restaurant_id}", response_model=List[Product])
def get_products(restaurant_id: str):
    for r in MOCK_RESTAURANTS:
        if r.id == restaurant_id:
            return r.products
    raise HTTPException(status_code=404, detail="Restaurant not found")
