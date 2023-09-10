#!/bin/sh

python3 -m venv .venv
source .venv/bin/activate 
.venv/bin/python -m pip install -r requirements.txt