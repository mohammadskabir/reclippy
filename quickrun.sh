#!/bin/sh
. /app/venv/bin/activate
gunicorn -b 0.0.0.0:8899 -w 1 --threads 4 --timeout 600 --access-logfile - app:app
