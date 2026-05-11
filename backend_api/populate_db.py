from main import SessionLocal, RestaurantDB, ProductDB, Base, engine

def populate_db():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        if not db.query(RestaurantDB).first():
            # Add products
            p1 = ProductDB(id="p1", name="Espresso", imageUrl="https://via.placeholder.com/150", price=2.50)
            p2 = ProductDB(id="p2", name="Latte", imageUrl="https://via.placeholder.com/150", price=3.50)
            p3 = ProductDB(id="p3", name="Croissant", imageUrl="https://via.placeholder.com/150", price=2.00)
            p4 = ProductDB(id="p4", name="Burger", imageUrl="https://via.placeholder.com/150", price=8.50)
            p5 = ProductDB(id="p5", name="Fries", imageUrl="https://via.placeholder.com/150", price=3.00)
            p6 = ProductDB(id="p6", name="Pizza", imageUrl="https://via.placeholder.com/150", price=12.00)
            p7 = ProductDB(id="p7", name="Soda", imageUrl="https://via.placeholder.com/150", price=1.50)
            p8 = ProductDB(id="p8", name="Ice Cream", imageUrl="https://via.placeholder.com/150", price=4.00)

            db.add_all([p1, p2, p3, p4, p5, p6, p7, p8])

            # Add restaurants
            r1 = RestaurantDB(id="r1", name="Cafe Mocha", address="123 Coffee St", latitude=40.7128, longitude=-74.0060, imageUrl="https://via.placeholder.com/300x150", products=[p1, p2, p3])
            r2 = RestaurantDB(id="r2", name="Burger Joint", address="456 Fast Food Ave", latitude=40.7138, longitude=-74.0070, imageUrl="https://via.placeholder.com/300x150", products=[p4, p5, p7, p8])
            r3 = RestaurantDB(id="r3", name="Downtown Diner", address="789 Downtown Blvd", latitude=40.7118, longitude=-74.0050, imageUrl="https://via.placeholder.com/300x150", products=[p1, p4, p5, p6])
            r4 = RestaurantDB(id="r4", name="Pizza Palace", address="321 Slice Rd", latitude=40.7150, longitude=-74.0080, imageUrl="https://via.placeholder.com/300x150", products=[p6, p7, p8])
            r5 = RestaurantDB(id="r5", name="Sweet Treats", address="654 Dessert Ln", latitude=40.7100, longitude=-74.0040, imageUrl="https://via.placeholder.com/300x150", products=[p8, p2, p1])

            db.add_all([r1, r2, r3, r4, r5])
            db.commit()
            print("Database populated successfully.")
        else:
            print("Database already contains data, skipping...")
    except Exception as e:
        print(f"Error populating db: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    populate_db()
