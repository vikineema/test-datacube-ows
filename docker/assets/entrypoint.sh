#!/bin/sh
set -e

echo "Starting Jupyter Lab in development mode..."
exec jupyter lab --config="$PYTHON_ENV/etc/jupyter/jupyter_lab_config.py"