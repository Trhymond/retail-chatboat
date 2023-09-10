FROM python:3.11.5-bullseye

RUN pip install --upgrade pip

RUN adduser -D myuser
USER myuser
WORKDIR /home/myuser

COPY --chown=myuser:myuser ./app/backend/requirements.txt /tmp/requirements.txt
RUN pip install --user --no-cache-dir -r /tmp/requirements.txt

COPY --chown=myuser:myuser ./app/backend/start.sh /start.sh
RUN chmod +x /start.sh

COPY --chown=myuser:myuser ./app/backend/gunicorn.conf.py /gunicorn.conf.py

COPY --chown=myuser:myuser ./app/backend/start-reload.sh /start-reload.sh
RUN chmod +x /start-reload.sh

COPY --chown=myuser:myuser ./app/backend/src /app
WORKDIR /app

EXPOSE 80
EXPOSE 443
CMD ["/start.sh"]
