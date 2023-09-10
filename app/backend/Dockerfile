FROM python:3.11.5-bullseye

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

COPY start.sh /start.sh
RUN chmod +x /start.sh

COPY gunicorn.conf.py /gunicorn.conf.py

COPY start-reload.sh /start-reload.sh
RUN chmod +x /start-reload.sh

COPY ./src /app
WORKDIR /app

EXPOSE 80

CMD ["/start.sh"]
