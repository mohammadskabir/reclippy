FROM alpine:latest

# apk add git

RUN apk --no-cache --update-cache upgrade && \
    apk --no-cache add python3 py3-pip && \
    apk --no-cache add ffmpeg && \
    apk --no-cache add deno && \
    rm -rf /tmp/* /var/tmp/*

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    HOST=0.0.0.0 \
    PORT=8899

WORKDIR /app

# git clone https://github.com/averygan/reclip app && rm -rf /app/assets
COPY . .



RUN cp /app/templates/wsl.conf /etc/wsl.conf && \
    mkdir -p cookies && \
    mkdir -p downloads && \
    addgroup reclippy && \
    adduser -G reclippy -D reclippy && \
    chown -R reclippy:reclippy /app

USER reclippy

# Using a python virtualenv instead of pipx means less installation overhead.
ENV VIRTUAL_ENV=/app/venv
RUN python3 -m venv $VIRTUAL_ENV && \
    . /app/venv/bin/activate && \
    pip install --upgrade --no-cache-dir pip && \
    pip install --no-cache-dir -U --pre -r /app/requirements.txt && \
    cp /app/templates/yt-dlp.conf /app/venv/bin/
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

EXPOSE 8899
# CMD ["python", "app.py"]
CMD ["gunicorn", "-b", "0.0.0.0:8899", "-w", "1", "--threads", "4", "--timeout", "600", "--access-logfile", "-", "app:app"]
