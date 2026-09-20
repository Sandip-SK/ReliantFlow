FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN python -m pip install --no-cache-dir -r requirements.txt

COPY app/ ./app/

RUN useradd \
    --create-home \
    --uid 10001 \
    --shell /bin/bash \
    appuser \
    && chown -R 10001:10001 /app

USER 10001

EXPOSE 8080

CMD ["python", "app/main.py"]