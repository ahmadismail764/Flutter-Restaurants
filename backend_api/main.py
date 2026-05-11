from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr, ConfigDict
from typing import Optional, List
from sqlalchemy import create_engine, Column, Integer, String, Float, Table, ForeignKey
from sqlalchemy.orm import sessionmaker, Session, declarative_base, relationship
import secrets

# 1. Database Configuration
SQLALCHEMY_DATABASE_URL = "sqlite:///./sql_app.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# 2. Database Models
restaurant_product_association = Table(
    'restaurant_product',
    Base.metadata,
    Column('restaurant_id', String, ForeignKey('restaurants.id'), primary_key=True),
    Column('product_id', String, ForeignKey('products.id'), primary_key=True)
)

class UserDB(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    email = Column(String, unique=True, index=True)
    password = Column(String) # Plaintext for demo only, hash in production
    gender = Column(String, nullable=True)
    level = Column(Integer, nullable=True)

class ProductDB(Base):
    __tablename__ = "products"
    id = Column(String, primary_key=True, index=True)
    name = Column(String, index=True)
    imageUrl = Column(String)
    price = Column(Float)

class RestaurantDB(Base):
    __tablename__ = "restaurants"
    id = Column(String, primary_key=True, index=True)
    name = Column(String, index=True)
    address = Column(String)
    latitude = Column(Float)
    longitude = Column(Float)
    imageUrl = Column(String)
    products = relationship("ProductDB", secondary=restaurant_product_association)

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

    model_config = ConfigDict(from_attributes=True)

class Product(BaseModel):
    id: str
    name: str
    imageUrl: str
    price: float

    model_config = ConfigDict(from_attributes=True)

class Restaurant(BaseModel):
    id: str
    name: str
    address: str
    latitude: float
    longitude: float
    imageUrl: str
    products: List[Product]

    model_config = ConfigDict(from_attributes=True)

# 4. FastAPI App Initialization
app = FastAPI(title="Restaurant API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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
    if not db_user or not secrets.compare_digest(db_user.password.encode('utf-8'), user.password.encode('utf-8')):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    return db_user

@app.get("/restaurants", response_model=List[Restaurant])
def get_restaurants(db: Session = Depends(get_db)):
    return db.query(RestaurantDB).all()

@app.get("/products/{restaurant_id}", response_model=List[Product])
def get_products(restaurant_id: str, db: Session = Depends(get_db)):
    restaurant = db.query(RestaurantDB).filter(RestaurantDB.id == restaurant_id).first()
    if not restaurant:
        raise HTTPException(status_code=404, detail="Restaurant not found")
    return restaurant.products

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
