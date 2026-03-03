#!/usr/bin/env python3
import psycopg2
from psycopg2 import sql
import csv
import json

# Connect to PostgreSQL
conn = psycopg2.connect(
    host="localhost",
    port=5432,
    user="postgres",
    password="postgres",
    database="lakehouse"
)
cur = conn.cursor()

# Create bronze schema
cur.execute("CREATE SCHEMA IF NOT EXISTS bronze;")
print("✅ Created bronze schema")

# Load customers CSV
print("Loading customers data...")
cur.execute("""
    DROP TABLE IF EXISTS bronze.customers;
    CREATE TABLE bronze.customers (
        customer_id INTEGER,
        name VARCHAR,
        email VARCHAR,
        phone VARCHAR,
        address VARCHAR,
        city VARCHAR,
        state VARCHAR,
        zip_code VARCHAR,
        join_date VARCHAR
    )
""")

with open('data/ecoride_customers.csv', 'r') as f:
    cur.copy_expert(
        "COPY bronze.customers FROM STDIN WITH CSV HEADER",
        f
    )
print("✅ Loaded customers data")

# Load sales CSV
print("Loading sales data...")
cur.execute("""
    DROP TABLE IF EXISTS bronze.sales;
    CREATE TABLE bronze.sales (
        sales_id INTEGER,
        customer_id INTEGER,
        vehicle_id INTEGER,
        sale_date VARCHAR,
        amount DECIMAL,
        status VARCHAR
    )
""")

with open('data/ecoride_sales.csv', 'r') as f:
    cur.copy_expert(
        "COPY bronze.sales FROM STDIN WITH CSV HEADER",
        f
    )
print("✅ Loaded sales data")

# Load vehicles CSV
print("Loading vehicles data...")
cur.execute("""
    DROP TABLE IF EXISTS bronze.vehicles;
    CREATE TABLE bronze.vehicles (
        id INTEGER,
        model_name VARCHAR,
        model_type VARCHAR,
        battery_capacity INTEGER,
        range INTEGER,
        color VARCHAR,
        year INTEGER,
        charging_time INTEGER
    )
""")

with open('data/ecoride_vehicles.csv', 'r') as f:
    cur.copy_expert(
        "COPY bronze.vehicles FROM STDIN WITH CSV HEADER",
        f
    )
print("✅ Loaded vehicles data")

conn.commit()
print("\n🎉 All bronze layer data loaded successfully!")
cur.close()
conn.close()
