FROM alpine:latest

# RUN echo 'nameserver 9.9.9.9' > /etc/resolv.conf
# apk add git
# git clone https://github.com/averygan/reclip app && rm -rf /app/assets
# ENV HOST=0.0.0.0
# CMD ["python", "app.py"]

RUN apk --no-cache --update-cache upgrade && \
    apk --no-cache add python3 py3-pip ffmpeg deno

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

COPY . .

RUN mkdir -p cookies && \
    mkdir -p downloads && \
    addgroup reclip && \
    adduser -G reclip -D reclip && \
    chown -R reclip:reclip /app

USER reclip

ENV VIRTUAL_ENV=/app/venv
RUN python3 -m venv $VIRTUAL_ENV && \
    . /app/venv/bin/activate && \
    pip install --upgrade --no-cache-dir pip && \
    pip install --no-cache-dir -U --pre -r /app/requirements.txt && \
    cp /app/templates/yt-dlp.conf /app/venv/bin/
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

EXPOSE 8899
CMD ["gunicorn", "-b", "0.0.0.0:8899", "-w", "1", "--threads", "4", "--timeout", "600", "--access-logfile", "-", "app:app"]
