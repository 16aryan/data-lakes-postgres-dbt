from pyspark.sql import SparkSession
from dotenv import load_dotenv
import os

load_dotenv(os.path.join(os.path.dirname(__file__), "../..", ".env"))

def create_spark_session():
    return SparkSession.builder \
        .appName("Data Ingestion to Bronze with Iceberg") \
        .config(
            "spark.jars.packages",
            "org.apache.iceberg:iceberg-spark-runtime-3.3_2.12:1.3.1,"
            "org.projectnessie.nessie-integrations:nessie-spark-extensions-3.3_2.12:0.67.0,"
            "software.amazon.awssdk:bundle:2.17.178,"
            "software.amazon.awssdk:url-connection-client:2.17.178",
        ) \
        .config(
            "spark.sql.extensions",
            "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions,"
            "org.projectnessie.spark.extensions.NessieSparkSessionExtensions",
        ) \
        .config("spark.sql.catalog.nessie", "org.apache.iceberg.spark.SparkCatalog") \
        .config("spark.sql.catalog.nessie.uri", "http://localhost:19120/api/v1") \
        .config("spark.sql.catalog.nessie.ref", "main") \
        .config("spark.sql.catalog.nessie.authentication.type", "NONE") \
        .config("spark.sql.catalog.nessie.catalog-impl", "org.apache.iceberg.nessie.NessieCatalog") \
        .config("spark.sql.catalog.nessie.s3.endpoint", os.environ.get("AWS_S3_ENDPOINT")) \
        .config("spark.sql.catalog.nessie.warehouse", os.environ.get("LAKEHOUSE_S3_PATH")) \
        .config("spark.sql.catalog.nessie.io-impl", "org.apache.iceberg.aws.s3.S3FileIO") \
        .config("spark.hadoop.fs.s3a.endpoint", os.environ.get("AWS_S3_ENDPOINT")) \
        .config("spark.hadoop.fs.s3a.path.style.access", "true") \
        .config("spark.hadoop.fs.s3a.access.key", os.environ.get("AWS_ACCESS_KEY_ID")) \
        .config("spark.hadoop.fs.s3a.secret.key", os.environ.get("AWS_SECRET_ACCESS_KEY")) \
        .config("spark.sql.hive.metastore.jars", "builtin") \
        .config("datanucleus.schema.autoCreateTables", "true") \
        .getOrCreate()