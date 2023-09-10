#! /usr/bin/env sh
set -e

export PYTHONPATH=./src

exec gunicorn -k 'uvicorn.workers.UvicornWorker' -c './gunicorn.conf.py' src.main:app