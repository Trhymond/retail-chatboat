FROM python:3.11.5-bullseye

COPY ./app/backend/requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

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
