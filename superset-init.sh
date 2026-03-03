#!/bin/bash
# Superset initialization script with error handling and environment variables
# This script is idempotent - safe to run multiple times

set +e  # Don't exit on errors

echo "🚀 Starting Superset initialization..."

# Wait for database to be ready
echo "⏳ Waiting for database..."
sleep 10

# Install Dremio driver
echo "📦 Installing Dremio driver..."
pip install --no-cache-dir sqlalchemy-dremio 2>/dev/null || {
    echo "⚠️  Could not install sqlalchemy-dremio, skipping..."
}

# Initialize the database
echo "🗄️  Initializing Superset database..."
superset db upgrade 2>&1 | grep -v "already exists"

# Create admin user if it doesn't exist
echo "👤 Setting up admin user..."
SUPERSET_ADMIN_USER="${SUPERSET_ADMIN_USER:-admin}"
SUPERSET_ADMIN_PASSWORD="${SUPERSET_ADMIN_PASSWORD:-admin}"
SUPERSET_ADMIN_EMAIL="${SUPERSET_ADMIN_EMAIL:-admin@example.com}"

# Try to create admin user; if it fails (user exists), that's OK
superset fab create-admin \
    --username "$SUPERSET_ADMIN_USER" \
    --firstname "Admin" \
    --lastname "User" \
    --email "$SUPERSET_ADMIN_EMAIL" \
    --password "$SUPERSET_ADMIN_PASSWORD" 2>/dev/null || {
    echo "ℹ️  Admin user already exists or has different credentials"
}

# Initialize Superset
echo "⚙️  Initializing Superset..."
superset init 2>&1 | grep -v "already exists" || true

# Start the Superset server
echo "✅ Starting Superset server on 0.0.0.0:8088"
superset run -h 0.0.0.0 -p 8088

