#!/bin/sh

# python3 -m venv .venv
# source .venv/bin/activate
# .venv/bin/python3 -m pip install -r requirements.txt

docker build -t chatbot-backend -f Dockerfile .
docker tag chatbot-backend rhymtestacr001.azurecr.io/chatbot-backend:1.0.0
docker push rhymtestacr001.azurecr.io/chatbot-backend:1.0.0