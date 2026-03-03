#!/bin/bash
# Complete lakehouse initialization and data pipeline with error handling

set +e  # Don't exit on errors - we want to handle them gracefully

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV="$SCRIPT_DIR/.venv"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting Complete Lakehouse Setup...${NC}\n"

# Function to wait for service
wait_for_service() {
    local host=$1
    local port=$2
    local service=$3
    local max_attempts=30
    local attempt=0

    echo -e "${BLUE}⏳ Waiting for $service to be ready...${NC}"
    while [ $attempt -lt $max_attempts ]; do
        if nc -z $host $port 2>/dev/null; then
            echo -e "${GREEN}✅ $service is ready${NC}"
            return 0
        fi
        attempt=$((attempt + 1))
        echo -n "."
        sleep 1
    done
    echo -e "${RED}❌ Timeout waiting for $service${NC}"
    return 1
}

# 1. Start Docker containers
echo -e "\n${BLUE}1️⃣  Starting Docker containers...${NC}"
if docker-compose up -d 2>/dev/null; then
    echo -e "${GREEN}✅ Docker containers started${NC}"
else
    echo -e "${YELLOW}⚠️  Docker compose had issues, but continuing...${NC}"
fi

# 2. Wait for services to be healthy
echo -e "\n${BLUE}2️⃣  Waiting for services to be healthy...${NC}"
wait_for_service localhost 5432 "PostgreSQL" || true
wait_for_service localhost 9047 "Dremio" || true
wait_for_service localhost 9000 "MinIO" || true
wait_for_service localhost 19120 "Nessie" || true
wait_for_service localhost 8088 "Superset" || true
sleep 5  # Extra buffer for services to fully initialize

echo -e "${GREEN}✅ Services initialization complete${NC}"

# 3. Load bronze layer data
echo -e "\n${BLUE}3️⃣  Loading bronze layer data...${NC}"
if command -v python3 &> /dev/null; then
    if python3 "$SCRIPT_DIR/load_bronze_data.py"; then
        echo -e "${GREEN}✅ Bronze data loaded successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  Bronze data loading had issues, but continuing...${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Python3 not found, skipping bronze data load${NC}"
fi

# 4. Run silver transformations
echo -e "\n${BLUE}4️⃣  Running silver layer transformations...${NC}"
if [ -f "$VENV/bin/activate" ]; then
    cd "$SCRIPT_DIR/transformation/silver" || exit 1
    if source "$VENV/bin/activate" && dbt run --project-dir . 2>&1 | tail -20; then
        echo -e "${GREEN}✅ Silver transformations completed${NC}"
    else
        echo -e "${YELLOW}⚠️  Silver transformations had issues, but continuing...${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Virtual environment not found, skipping silver transformations${NC}"
fi

# 5. Run gold transformations
echo -e "\n${BLUE}5️⃣  Running gold layer transformations...${NC}"
if [ -f "$VENV/bin/activate" ]; then
    cd "$SCRIPT_DIR/transformation/gold" || exit 1
    if source "$VENV/bin/activate" && dbt run --project-dir . 2>&1 | tail -20; then
        echo -e "${GREEN}✅ Gold transformations completed${NC}"
    else
        echo -e "${YELLOW}⚠️  Gold transformations had issues, but continuing...${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Virtual environment not found, skipping gold transformations${NC}"
fi

# Summary
echo -e "\n${BLUE}════════════════════════════════════════${NC}"
echo -e "${GREEN}🎉 Lakehouse Setup Complete!${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Available Services:${NC}"
echo -e "  📊 Superset:   http://localhost:8088"
echo -e "  🧠 JupyterLab: http://localhost:8888"
echo -e "  🔍 Dremio:     http://localhost:9047"
echo -e "  💾 MinIO:      http://localhost:9000"
echo -e "  📋 Nessie:     http://localhost:19120"
echo -e "  🐘 PostgreSQL: localhost:5432"
echo ""
echo -e "${YELLOW}To check service status:${NC}"
echo "  docker-compose ps"
echo ""
echo -e "${YELLOW}To view logs:${NC}"
echo "  docker-compose logs -f [service_name]"
echo ""
echo -e "${YELLOW}To stop all services:${NC}"
echo "  docker-compose down"
echo ""
