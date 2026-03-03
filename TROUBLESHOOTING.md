# Troubleshooting Guide

## Common Issues and Solutions

### Services Not Starting

**Problem**: Docker containers fail to start

**Solution**:
```bash
# Check container logs
docker-compose logs -f postgres
docker-compose logs -f dremio

# Restart all services
docker-compose restart

# Full reset (removes all data)
docker-compose down -v
docker-compose up -d

# Run setup script again
./setup.sh
```

### PostgreSQL Connection Issues

**Problem**: Cannot connect to PostgreSQL

**Solution**:
```bash
# Check if PostgreSQL is running
docker-compose ps postgres

# Check PostgreSQL logs
docker-compose logs postgres

# Verify connection from host
docker exec -it postgres psql -U postgres -d lakehouse -c "SELECT 1"

# Reset PostgreSQL container
docker-compose restart postgres
sleep 5
python3 load_bronze_data.py
```

### Dremio Not Responding

**Problem**: Dremio UI not accessible at localhost:9047

**Solution**:
```bash
# Check Dremio status
docker-compose ps dremio

# View Dremio logs
docker-compose logs -f dremio

# Restart Dremio
docker-compose restart dremio

# Wait for health check
sleep 30
docker-compose ps dremio
```

### Data Loading Failed

**Problem**: `load_bronze_data.py` fails

**Solution**:
```bash
# Check if PostgreSQL is ready
docker exec -it postgres pg_isready -U postgres

# View data file existence
ls -la data/

# Check file permissions
chmod 644 data/*.csv

# Retry data loading
python3 load_bronze_data.py

# If that fails, check error log
python3 load_bronze_data.py 2>&1 | tail -50
```

### dbt Transformations Fail

**Problem**: dbt run exits with errors

**Solution**:
```bash
# Verify Python environment
source .venv/bin/activate
which dbt

# Check dbt version
dbt --version

# Verify database connection
dbt debug --project-dir transformation/silver

# Clear cache and try again
rm -rf transformation/silver/target
cd transformation/silver
dbt deps  # Install dependencies
dbt parse  # Parse project
dbt run --project-dir .

# Check detailed error
dbt run --project-dir . --debug 2>&1 | tail -100
```

### Port Already in Use

**Problem**: Port (e.g., 5432) already in use

**Solution**:
```bash
# Find process using port (macOS/Linux)
lsof -i :5432

# Kill process
kill -9 <PID>

# Or change port in docker-compose.yml and restart
# Edit the port mapping: "5433:5432" instead of "5432:5432"
docker-compose down
docker-compose up -d
```

### Disk Space Issues

**Problem**: Docker containers fail due to disk space

**Solution**:
```bash
# Remove unused Docker resources
docker system prune -a --volumes

# Check disk usage
docker system df

# Clean up old images
docker image prune -a

# Restart services
docker-compose up -d
```

### Service Health Check Failing

**Problem**: Services show "health: unhealthy"

**Solution**:
```bash
# Check detailed service status
docker-compose ps

# View service logs
docker-compose logs <service_name>

# Increase health check timeout in docker-compose.yml
# Restart services
docker-compose restart

# Wait longer for services
sleep 60
docker-compose ps
```

### MinIO Not Accessible

**Problem**: MinIO console not loading

**Solution**:
```bash
# Check MinIO is running
docker-compose ps minio

# Try direct API access
curl -i http://localhost:9000/minio/health/live

# View logs
docker-compose logs minio

# Restart MinIO
docker-compose restart minio

# Wait for health check
sleep 15
docker-compose ps minio
```

### Nessie Connection Issues

**Problem**: Cannot connect to Nessie

**Solution**:
```bash
# Check Nessie endpoint
curl -i http://localhost:19120/api/v1/config

# Check logs
docker-compose logs nessie

# Restart Nessie
docker-compose restart nessie

# Verify with curl
curl -s http://localhost:19120/api/v1/config | jq .
```

## Network Issues

### Container-to-Container Communication

**Problem**: Containers can't reach each other

**Solution**:
- All containers are on the same network: `lakehousenet`
- Use container name as hostname (e.g., `postgres:5432`)
- Verify with: `docker network inspect lakehousenet`

```bash
# Check network
docker network inspect lakehousenet

# Test connectivity
docker exec -it postgres ping dremio
docker exec -it dremio curl http://postgres:5432
```

## Performance Issues

### Slow Transformations

**Problem**: dbt transformations taking too long

**Optimization**:
```bash
# Increase dbt threads in profiles.yml
# Change "threads: 4" to higher value

# Run with more verbosity to see bottlenecks
dbt run --debug

# Profile queries
dbt test --debug

# Check PostgreSQL performance
docker exec -it postgres psql -U postgres -d lakehouse -c "
  SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) 
  FROM pg_tables 
  WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
  ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
"
```

## Verification Commands

### Check All Services

```bash
# Complete system status
docker-compose ps

# All logs
docker-compose logs

# Database status
docker exec -it postgres psql -U postgres -d lakehouse -c "
  SELECT 'bronze' as layer, COUNT(*) FROM information_schema.tables WHERE table_schema='bronze'
  UNION ALL
  SELECT 'silver', COUNT(*) FROM information_schema.tables WHERE table_schema='silver'
  UNION ALL
  SELECT 'gold', COUNT(*) FROM information_schema.tables WHERE table_schema='gold' AND table_type='VIEW';
"
```

## Getting Help

If issues persist:

1. **Check logs**: `docker-compose logs [service_name]`
2. **Verify prerequisites**: Docker, Python 3.11+, 8GB+ RAM
3. **Try fresh start**: `docker-compose down -v && docker-compose up -d && ./setup.sh`
4. **Review README.md**: Check for any missed configuration steps
5. **Check GitHub issues**: Look for similar problems reported

## Quick Recovery

If everything is broken:

```bash
# Nuclear option - complete reset
docker-compose down -v
rm -rf transformation/silver/target
rm -rf transformation/gold/target
rm -rf .venv
rm -rf postgres_data minio_data

# Start fresh
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

./setup.sh
```
