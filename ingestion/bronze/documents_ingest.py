from ingestion.utils.spark_utils import create_spark_session
from ingestion.utils.config_loader import ConfigLoader
from ingestion.utils.file_path_manager import FilePathManager
import os

if __name__ == "__main__":
    config = ConfigLoader()

    # Ingest all PDF documents in a folder to the Bronze layer
    pdf_folder = os.path.join(config.base_data_dir, "documents")

    print(f"\n=== Ingesting documents from {pdf_folder} ===")

    # Iterate through all files in the folder and show each PDF
    pdf_count = 0
    for filename in os.listdir(pdf_folder):
        if filename.endswith(".pdf"):
            pdf_file = os.path.join(pdf_folder, filename)
            file_size = os.path.getsize(pdf_file)
            pdf_count += 1
            print(f"Document {pdf_count}: {filename} ({file_size} bytes)")

    print(f"\nTotal documents found: {pdf_count}")
    print("Document ingestion simulation complete - files are ready for processing")
    print("=" * 50)
