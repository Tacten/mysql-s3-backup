FROM alpine:latest as cron
LABEL org.opencontainers.image.authors="d3fk"
LABEL org.opencontainers.image.source="https://github.com/Tacten/mysql-s3-backup.git"
LABEL org.opencontainers.image.url="https://github.com/Tacten/mysql-s3-backup"

RUN apk upgrade --no-cache \
  && apk add --no-cache mysql-client python3 py3-six py3-pip py3-setuptools libmagic git ca-certificates jq \
  && git clone https://github.com/s3tools/s3cmd.git /tmp/s3cmd \
  && cd /tmp/s3cmd \
  && pip install python-dateutil python-magic --break-system-packages\
  && python3 /tmp/s3cmd/setup.py install \
  && cd / \
  && apk del py3-pip git \
  && rm -rf /root/.cache/pip /tmp/s3cmd 

COPY backup-cron /etc/cron.d/backup-cron

COPY backup-script.sh /backup-script.sh

RUN chmod +x /backup-script.sh

RUN crontab /etc/cron.d/backup-cron

WORKDIR /s3

CMD crond -f