FROM python:3.11.5-bullseye

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY ./app/backend/requirements.txt /tmp/requirements.txt
RUN /opt/venv/python -m pip install --no-cache-dir -r /tmp/requirements.txt

COPY ./app/backend/start.sh /start.sh
RUN chmod +x /start.sh

COPY ./app/backend/gunicorn.conf.py /gunicorn.conf.py

COPY ./app/backend/start-reload.sh /start-reload.sh
RUN chmod +x /start-reload.sh

COPY ./app/backend/src /app
WORKDIR /app

EXPOSE 80
EXPOSE 443
CMD ["/start.sh"]
