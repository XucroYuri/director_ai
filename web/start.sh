#!/bin/bash

set -e

echo "============================================"
echo "     AI Storyboard Pro v2.0"
echo "     AI Smart Storyboard System"
echo "============================================"
echo

cd "$(dirname "$0")"

VENV_DIR=".venv"
PYTHON="${PYTHON:-python3}"

# Check and kill process on port 7861
echo "[1/4] Checking port 7861..."
PID=$(lsof -t -i:7861 2>/dev/null || true)
if [ -n "$PID" ]; then
    echo "       Found process (PID: $PID)"
    echo "       Killing..."
    kill -9 $PID 2>/dev/null || true
fi
echo "       Port 7861 cleared"

echo
echo "[2/4] Checking dependencies..."
if [ ! -d "$VENV_DIR" ]; then
    echo "       Creating virtualenv ($VENV_DIR)..."
    "$PYTHON" -m venv "$VENV_DIR"
fi

PIP="$VENV_DIR/bin/pip"
PY="$VENV_DIR/bin/python"

if ! "$PIP" show gradio >/dev/null 2>&1; then
    echo "       Installing dependencies..."
    "$PIP" install -r requirements.txt
else
    echo "       Dependencies OK"
fi

echo
echo "[3/4] Checking configuration..."
if [ ! -f ".env" ]; then
    echo "       No configuration found."
    echo "       Running setup wizard..."
    echo
    "$PY" setup_wizard.py
else
    echo "       Configuration OK"
fi

echo
echo "[4/4] Starting server..."
echo
echo "============================================"
echo "   Server URL: http://127.0.0.1:7861"
echo "   Press Ctrl+C to stop"
echo "============================================"
echo

exec "$PY" app.py
