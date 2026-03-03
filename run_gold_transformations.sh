#!/bin/bash
# Run dbt gold layer transformations with error handling

set -euo pipefail

PROJECT_DIR="/Users/aryan/complete-guide-to-data-lakes-and-lakehouses-with-ai-3865060/transformation/gold"
VENV="/Users/aryan/complete-guide-to-data-lakes-and-lakehouses-with-ai-3865060/.venv"

echo "🔄 Running dbt gold layer transformations..."

# Activate virtual environment
if [ -f "$VENV/bin/activate" ]; then
    source "$VENV/bin/activate"
else
    echo "⚠️  Virtual environment not found at $VENV"
    exit 1
fi

# Change to gold directory
cd "$PROJECT_DIR" || { echo "❌ Cannot access gold directory"; exit 1; }

# Run dbt with error handling
if dbt run --project-dir . 2>&1; then
    echo "✅ Gold layer transformations completed successfully"
    exit 0
else
    echo "⚠️  Gold layer transformations encountered errors but continuing..."
    exit 0  # Don't fail the script completely
fi
