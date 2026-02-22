from pyspark.sql import SparkSession
import logging

class DataIngestor:
    def __init__(self, spark: SparkSession):
        self.spark = spark

    def ingest_file_to_bronze(self, file_path: str, business_entity: str, table_name: str, file_type: str, partition_by=None):
        try:
            if file_type == 'csv':
                df = self.spark.read.csv(file_path, header=True, inferSchema=True)
            elif file_type == 'json':
                df = self.spark.read.option("multiLine", "true").json(file_path)
            else:
                raise ValueError(f"Unsupported file type '{file_type}'. Supported types: csv, json")

            # For now, just show the data and schema to verify ingestion works
            print(f"\n=== Ingesting {business_entity}.{table_name} from {file_path} ===")
            print(f"Schema for {table_name}:")
            df.printSchema()
            print(f"Row count: {df.count()}")
            print("Sample data:")
            df.show(5, truncate=False)
            print("=" * 50)

            logging.info(f"Data ingested successfully from {file_path} to Spark DataFrame for {business_entity}.{table_name}")

        except Exception as e:
            logging.error(f"Error in ingesting file to DataFrame: {e}")
            raise e


