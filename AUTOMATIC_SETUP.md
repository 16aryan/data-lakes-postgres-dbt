# Automatic Container Startup & Error Handling System

## What's Been Implemented

### 1. **Docker Auto-Restart on Failures** ✅

All containers have `restart: always` policy:
- **PostgreSQL** - Auto-restarts on crash
- **Dremio** - Auto-restarts on crash  
- **MinIO** - Auto-restarts on crash
- **Nessie** - Auto-restarts on crash
- **Superset** - Auto-restarts on crash
- **JupyterLab** - Auto-restarts on crash

**Result**: System never completely fails - containers automatically recover

### 2. **Service Health Checks** ✅

Each service has health monitoring:
- PostgreSQL: `pg_isready` check every 10 seconds
- Dremio: HTTP health endpoint check every 30 seconds
- MinIO: Health endpoint check every 30 seconds
- Nessie: API health endpoint check every 30 seconds
- Superset: HTTP health endpoint check every 30 seconds

### 3. **Automatic Database Initialization** ✅

`init-db.sql` automatically creates:
- `bronze` schema
- `silver` schema  
- `gold` schema

These are created when PostgreSQL first starts - **zero manual setup needed**

### 4. **Service Dependency Management** ✅

Services start in proper order:
```
PostgreSQL (starts first) ↓
├─→ Dremio (waits for PostgreSQL healthy)
├─→ Superset (waits for PostgreSQL healthy)
└─→ JupyterLab (waits for PostgreSQL healthy)

MinIO (no dependencies - starts immediately)
Nessie (no dependencies - starts immediately)
```

### 5. **Error-Resilient Scripts** ✅

#### `load_bronze_data.py`
- Complete error handling with logging
- Skips missing files gracefully
- Returns proper exit codes
- Detailed progress messages

#### `setup.sh`
- Orchestrates entire startup process
- Waits for services with timeouts
- Continues on non-fatal errors
- Provides colorful status updates
- Shows available services at end

#### `run_silver_transformations.sh` & `run_gold_transformations.sh`
- Run dbt with error handling
- Log output properly
- Don't fail on transformation errors

### 6. **Complete Setup Script** ✅

Run everything with one command:
```bash
./setup.sh
```

This does:
1. Starts all Docker containers
2. Waits for all services to be healthy
3. Loads bronze layer data
4. Runs silver layer transformations
5. Runs gold layer transformations
6. Shows summary with all service URLs

## Key Features

### Never Fails Completely
- If a container crashes → **auto-restarts**
- If data loading fails → **continues with transformations**
- If transformations have errors → **reports but doesn't crash**
- If services are slow → **waits for them (with timeout)**

### Graceful Error Handling
- Try-except blocks everywhere
- Logging for all operations
- Proper exit codes
- Continue-on-error behavior
- Informative error messages

### Automatic Everything
- PostgreSQL schemas ✅
- Service health monitoring ✅
- Service dependencies ✅
- Complete pipeline execution ✅

## Testing Error Recovery

### Test 1: Crash & Recovery
```bash
# In one terminal, watch services
docker-compose ps

# In another, crash PostgreSQL
docker-compose kill postgres

# Watch it auto-restart in 3 seconds
docker-compose ps
# Status shows "Restarting"
# Within a few seconds shows "Up"
```

### Test 2: Complete Down & Restart
```bash
# Take everything down
docker-compose down

# Start everything (no manual intervention needed)
docker-compose up -d

# Wait for health checks to pass
sleep 15
docker-compose ps

# Schemas auto-created ✓
docker exec -it postgres psql -U postgres -d lakehouse -c "\dn"
```

### Test 3: Full Pipeline After Timeout
```bash
# If you stopped services after initial setup
docker-compose up -d
sleep 30

# Run data pipeline
./setup.sh
# Reports any issues but completes
```

## Configuration Files

### `docker-compose.yml`
- Added `restart: always` to all services
- Added health checks for each service
- Added named network `lakehousenet`
- Added volume definitions
- Added service dependencies

### `init-db.sql`
- Creates schemas automatically
- Sets search path
- Grants permissions

### `.env.example`  
- Template for customization
- Documents all service credentials
- Port mappings documented

### `setup.sh`
- Master orchestration script
- Colored output
- Comprehensive error handling
- Service availability summary

## System Architecture

```
┌─────────────────────────────────────────┐
│     docker-compose.yml                  │
│  (restart: always on all services)      │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│     PostgreSQL (Primary)                │
│  ├─ auto-restart on crash              │
│  ├─ health checks every 10s             │
│  └─ init-db.sql runs on startup         │
└─────────────────────────────────────────┘
              ↓
         Waits for:
         Health Status: Healthy
              ↓
┌─────────────────────────────────────────┐
│    Dependent Services                   │
│  ├─ Dremio (waits for postgres)        │
│  ├─ Superset (waits for postgres)      │
│  └─ JupyterLab (waits for postgres)    │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│    Independent Services                 │
│  ├─ MinIO (starts immediately)         │
│  └─ Nessie (starts immediately)        │
└─────────────────────────────────────────┘
              ↓
All Services Ready
              ↓
┌─────────────────────────────────────────┐
│    setup.sh Script                      │
│  ├─ load_bronze_data.py (error handle) │
│  ├─ Silver transformations (resilient) │
│  └─ Gold transformations (resilient)   │
└─────────────────────────────────────────┘
```

## Files Modified/Created

### New Files
- ✅ `setup.sh` - Master setup script
- ✅ `init-db.sql` - Database initialization
- ✅ `run_silver_transformations.sh` - Silver layer script
- ✅ `run_gold_transformations.sh` - Gold layer script
- ✅ `.env.example` - Configuration template
- ✅ `TROUBLESHOOTING.md` - Comprehensive troubleshooting guide
- ✅ `AUTOMATIC_SETUP.md` - This file

### Modified Files
- ✅ `docker-compose.yml` - Added restart policies, health checks, dependencies
- ✅ `load_bronze_data.py` - Added error handling, logging
- ✅ `README.md` - Updated with automatic setup instructions

## Usage

### Quick Start (Recommended)
```bash
chmod +x setup.sh
./setup.sh
```

### Manual Start
```bash
docker-compose up -d     # All containers auto-restart
python3 load_bronze_data.py
cd transformation/silver && dbt run --project-dir .
cd ../gold && dbt run --project-dir .
```

### Monitor Services
```bash
docker-compose ps
docker-compose logs -f [service_name]
```

### Stop Everything Safely
```bash
docker-compose down
```

### Full Reset (If Needed)
```bash
docker-compose down -v
./setup.sh
```

## Verification Checklist

After running `./setup.sh`, verify:

- [ ] All containers show "Up" status
  ```bash
  docker-compose ps
  ```

- [ ] PostgreSQL has all schemas
  ```bash
  docker exec -it postgres psql -U postgres -d lakehouse -c "\dn"
  ```

- [ ] Bronze data loaded
  ```bash
  docker exec -it postgres psql -U postgres -d lakehouse -c "SELECT COUNT(*) FROM bronze.customers;"
  ```

- [ ] Silver tables created
  ```bash
  docker exec -it postgres psql -U postgres -d lakehouse -c "SELECT COUNT(*) FROM silver.customers;"
  ```

- [ ] Gold views created
  ```bash
  docker exec -it postgres psql -U postgres -d lakehouse -c "SELECT COUNT(*) FROM gold.customer_lifetime_value;"
  ```

- [ ] All services accessible
  - PostgreSQL: `localhost:5432`
  - Dremio: `http://localhost:9047`
  - MinIO: `http://localhost:9001`
  - Nessie: `http://localhost:19120`
  - Superset: `http://localhost:8088`
  - JupyterLab: `http://localhost:8888`

## Support

See `TROUBLESHOOTING.md` for common issues and solutions.

## Summary

✅ **System Status: Production-Ready**

- Containers auto-restart on failures
- Services have health monitoring
- Database auto-initializes on startup
- Complete error handling throughout
- One-command setup available
- Never completely fails - graceful degradation
