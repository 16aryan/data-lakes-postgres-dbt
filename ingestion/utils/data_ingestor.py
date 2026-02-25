from pyspark.sql import SparkSession
import logging

class DataIngestor:
    def __init__(self, spark: SparkSession):
        self.spark = spark

    def create_or_replace_iceberg_table(self, df, layer, business_entity, table_name):
        schema = df.schema
        schema_sql = ", ".join([f"{field.name} {field.dataType.simpleString()}" for field in schema.fields])
        create_table_sql = (
            f"CREATE OR REPLACE TABLE nessie.{layer}.{business_entity}.{table_name} "
            f"({schema_sql}) USING iceberg"
        )

        try:
            self.spark.sql(f"CREATE NAMESPACE IF NOT EXISTS nessie.{layer};")
            self.spark.sql(f"CREATE NAMESPACE IF NOT EXISTS nessie.{layer}.{business_entity};")
            self.spark.sql(f"DROP TABLE IF EXISTS nessie.{layer}.{business_entity}.{table_name};")
            self.spark.sql(create_table_sql)
        except Exception as e:
            raise e

    def ingest_file_to_bronze(self, file_path: str, business_entity: str, table_name: str, file_type: str, partition_by=None):
        try:
            if file_type == 'csv':
                df = self.spark.read.csv(file_path, header=True, inferSchema=True)
            elif file_type == 'json':
                df = self.spark.read.option("multiLine", "true").json(file_path)
            else:
                raise ValueError(f"Unsupported file type '{file_type}'. Supported types: csv, json")

            full_table_path = f"nessie.bronze.{business_entity}.{table_name}"

            self.create_or_replace_iceberg_table(df, "bronze", business_entity, table_name)

            if partition_by:
                df.write.format("iceberg").partitionBy(partition_by).mode("overwrite").save(full_table_path)
            else:
                df.write.format("iceberg").mode("overwrite").save(full_table_path)

        except Exception as e:
            logging.error(f"Error in ingesting file to DataFrame: {e}")
            raise e


