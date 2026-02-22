from pyspark.sql import SparkSession
from dotenv import load_dotenv
import os

# Load .env file. This line assumes the .env file is in the parent directory of the script
load_dotenv(os.path.join(os.path.dirname(__file__), '../..', '.env'))

def create_spark_session():
    return SparkSession.builder \
        .appName("Data Ingestion to Bronze") \
        .config("spark.sql.hive.metastore.jars", "builtin") \
        .config("datanucleus.schema.autoCreateTables", "true") \
        .getOrCreate()