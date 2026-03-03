#!/usr/bin/env python3
"""
Load bronze layer data into PostgreSQL with error handling.
"""
import psycopg2
from psycopg2 import sql
import csv
import sys
import logging
from pathlib import Path

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def load_bronze_data():
    """Load all bronze layer data into PostgreSQL."""
    try:
        # Connect to PostgreSQL
        logger.info("Connecting to PostgreSQL...")
        conn = psycopg2.connect(
            host="localhost",
            port=5432,
            user="postgres",
            password="postgres",
            database="lakehouse"
        )
        cur = conn.cursor()
        logger.info("✅ Connected to PostgreSQL")

        # Create bronze schema if it doesn't exist
        cur.execute("CREATE SCHEMA IF NOT EXISTS bronze;")
        logger.info("✅ Bronze schema created/exists")

        # Load customers CSV
        customers_file = Path('data/ecoride_customers.csv')
        if customers_file.exists():
            logger.info("Loading customers data...")
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

            with open(customers_file, 'r') as f:
                cur.copy_expert(
                    "COPY bronze.customers FROM STDIN WITH CSV HEADER",
                    f
                )
            logger.info("✅ Loaded customers data")
        else:
            logger.warning(f"⚠️  {customers_file} not found, skipping customers")

        # Load sales CSV
        sales_file = Path('data/ecoride_sales.csv')
        if sales_file.exists():
            logger.info("Loading sales data...")
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

            with open(sales_file, 'r') as f:
                cur.copy_expert(
                    "COPY bronze.sales FROM STDIN WITH CSV HEADER",
                    f
                )
            logger.info("✅ Loaded sales data")
        else:
            logger.warning(f"⚠️  {sales_file} not found, skipping sales")

        # Load vehicles CSV
        vehicles_file = Path('data/ecoride_vehicles.csv')
        if vehicles_file.exists():
            logger.info("Loading vehicles data...")
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

            with open(vehicles_file, 'r') as f:
                cur.copy_expert(
                    "COPY bronze.vehicles FROM STDIN WITH CSV HEADER",
                    f
                )
            logger.info("✅ Loaded vehicles data")
        else:
            logger.warning(f"⚠️  {vehicles_file} not found, skipping vehicles")

        conn.commit()
        logger.info("\n🎉 All bronze layer data loaded successfully!")
        return True

    except psycopg2.Error as e:
        logger.error(f"Database error: {e}")
        return False
    except FileNotFoundError as e:
        logger.error(f"File not found: {e}")
        return False
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        return False
    finally:
        try:
            cur.close()
            conn.close()
        except:
            pass

if __name__ == "__main__":
    success = load_bronze_data()
    sys.exit(0 if success else 1)
