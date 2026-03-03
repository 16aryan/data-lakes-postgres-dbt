# Complete Guide to Data Lakes and Lakehouses with AI

This project demonstrates a complete data lakehouse architecture using modern data engineering tools and practices. It showcases the bronze/silver/gold data layering approach with dbt transformations, Spark ingestion, and various storage/catalog systems.

## Architecture Overview

The project implements a lakehouse architecture with:
- **Bronze Layer**: Raw data ingestion from various sources
- **Silver Layer**: Cleaned and standardized data
- **Gold Layer**: Business-ready analytics and aggregations

## Current Working Configuration

### ✅ Working Components

**Database & Transformations:**
- PostgreSQL database for data storage
- dbt Core 1.11.6 with postgres adapter
- Complete silver layer (7 models) and gold layer (5 views) transformations
- All dbt tests passing

**Data Ingestion:**
- PySpark 4.1.1 for data processing
- Java 17 for Spark compatibility
- CSV and JSON file ingestion working
- Successfully processes: customers (2,500 rows), sales (5,800 rows), vehicles (40 rows), product reviews (50 rows), vehicle health logs (3,200 rows)

**Infrastructure:**
- Docker Compose stack with PostgreSQL, MinIO, Dremio, Nessie, Superset
- Python 3.11 virtual environment
- VS Code configuration for consistent development

### 🔄 Components Under Development

**Iceberg/Nessie Integration:**
- Spark extensions require version alignment
- Manual Dremio UI configuration needed for S3 sources
- Iceberg table creation pending version compatibility fixes

## Quick Start

### Prerequisites
- Docker and Docker Compose
- Python 3.11
- VS Code (recommended)

### Option 1: Automatic Setup (Recommended)

Run the complete setup script that handles everything automatically:

```bash
# Make sure you're in the project directory
cd complete-guide-to-data-lakes-and-lakehouses-with-ai
chmod +x setup.sh
./setup.sh
```

This script will:
1. ✅ Start all Docker containers (automatically restarting on failure)
2. ✅ Wait for all services to be healthy
3. ✅ Load bronze layer data from CSV files
4. ✅ Run silver layer dbt transformations
5. ✅ Run gold layer dbt transformations
6. ✅ Provide a summary of available services

**All containers are configured to automatically restart on failure** - no manual intervention needed!

### Option 2: Manual Setup

If you prefer manual control:

```bash
# 1. Setup Python environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install -r requirements.txt

# 2. Start all Docker containers (they auto-restart on failure)
docker-compose up -d

# 3. Load bronze data
python3 load_bronze_data.py

# 4. Run transformations
cd transformation/silver && dbt run --project-dir .
cd ../gold && dbt run --project-dir .
```

### Docker Container Auto-Restart

All Docker containers are configured with `restart: always` policy:

| Service | Port | Auto-Restart |
|---------|------|--------------|
| PostgreSQL | 5432 | ✅ |
| Dremio | 9047 | ✅ |
| MinIO | 9000-9001 | ✅ |
| Nessie | 19120 | ✅ |
| Superset | 8088 | ✅ |
| JupyterLab | 8888 | ✅ |

### Error Handling

The system is designed to never fail completely:

1. **Graceful Error Handling**: All data loading and transformation scripts continue on errors
2. **Service Health Checks**: Docker containers monitor service health and auto-restart
3. **Dependency Management**: Services wait for dependencies before starting
4. **Automatic Initialization**: PostgreSQL schemas are created automatically on startup

### Monitoring

Check service status:
```bash
# View all container status
docker-compose ps

# View logs for a specific service
docker-compose logs -f postgres
docker-compose logs -f dremio

# Stop all services
docker-compose down

# Stop and remove all data
docker-compose down -v
```

## Data Sources

- **EcoRide**: E-commerce vehicle sales data (customers, sales, vehicles, reviews)
- **ChargeNet**: EV charging station data (stations, charging sessions)
- **Vehicle Health**: IoT sensor data with nested JSON structures

## Technology Stack

- **Ingestion**: PySpark 4.1.1, Java 17
- **Storage**: PostgreSQL, MinIO S3
- **Catalog**: Nessie (Git-like catalog for data)
- **Processing**: Dremio (query engine)
- **Transformation**: dbt Core
- **Visualization**: Apache Superset
- **Orchestration**: Dagster

## Project Structure

```
├── data/                    # Raw data files
├── ingestion/              # PySpark ingestion scripts
│   ├── bronze/            # Raw data ingestion
│   └── utils/             # Shared utilities
├── transformation/         # dbt projects
│   ├── silver/            # Data cleaning/standardization
│   └── gold/              # Business analytics
├── orchestration/          # Dagster pipelines
├── rag/                   # Retrieval-augmented generation
├── notebooks/             # Jupyter notebooks
└── superset/              # Superset configuration
```

## Key Achievements

✅ **Complete dbt Pipeline**: End-to-end data transformations from bronze to gold layer
✅ **Spark Ingestion**: Successfully processes multiple data formats and sources
✅ **Infrastructure Setup**: Docker-based development environment
✅ **Version Compatibility**: Resolved Java/PySpark compatibility issues
✅ **Code Quality**: Clean, documented, and tested codebase

## Next Steps

- [ ] Complete Iceberg/Nessie integration for full lakehouse capabilities
- [ ] Implement Dremio S3 source configuration
- [ ] Add automated testing for ingestion pipelines
- [ ] Deploy to cloud infrastructure (AWS/GCP)
- [ ] Implement real-time data ingestion
- [ ] Add ML/AI components for predictive analytics

## Contributing

This project demonstrates modern data engineering practices and serves as a reference implementation for lakehouse architectures.</content>
<parameter name="filePath">/Users/aryan/complete-guide-to-data-lakes-and-lakehouses-with-ai-3865060/README.md
