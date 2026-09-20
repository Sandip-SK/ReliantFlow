FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN python -m pip install --no-cache-dir -r requirements.txt

COPY app/ ./app/

RUN useradd --create-home --shell /bin/bash appuser \
    && chown -R appuser:appuser /app

USER appuser

EXPOSE 8080

CMD ["python", "app/main.py"]