#!/bin/bash
# Run dbt silver layer transformations with error handling

set -euo pipefail

PROJECT_DIR="/Users/aryan/complete-guide-to-data-lakes-and-lakehouses-with-ai-3865060/transformation/silver"
VENV="/Users/aryan/complete-guide-to-data-lakes-and-lakehouses-with-ai-3865060/.venv"

echo "🔄 Running dbt silver layer transformations..."

# Activate virtual environment
if [ -f "$VENV/bin/activate" ]; then
    source "$VENV/bin/activate"
else
    echo "⚠️  Virtual environment not found at $VENV"
    exit 1
fi

# Change to silver directory
cd "$PROJECT_DIR" || { echo "❌ Cannot access silver directory"; exit 1; }

# Run dbt with error handling
if dbt run --project-dir . 2>&1; then
    echo "✅ Silver layer transformations completed successfully"
    exit 0
else
    echo "⚠️  Silver layer transformations encountered errors but continuing..."
    exit 0  # Don't fail the script completely
fi
