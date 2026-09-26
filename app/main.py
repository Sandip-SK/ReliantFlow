import logging
import os

from flask import Flask, jsonify, request
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
metrics = PrometheusMetrics(app)

APP_VERSION = os.getenv("APP_VERSION", "1.0.0")

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s"
)

logger = logging.getLogger(__name__)

@app.route("/admin")
def admin():
    logger.info("Admin endpoint accessed")
    return jsonify({
        "message": "admin endpoint"
    })


@app.route("/")
def home():
    return jsonify({
        "service": "ReliantFlow",
        "status": "healthy",
        "version": APP_VERSION
    })


@app.route("/calculate")
def calculate():
    value = int(request.args.get("value", 10))

    logger.info("Calculate request received with value=%s", value)

    if value > 100:
        return jsonify({"result": "high"})

    if value < 0:
        return jsonify({"result": "negative"})

    if value == 10:
        return jsonify({"result": "exact"})

    return jsonify({"result": "normal"})


@app.route("/health")
def health():
    logger.info("Health check endpoint accessed")
    return jsonify({
        "status": "healthy"
    })


@app.route("/version")
def version():
    logger.info("Version endpoint accessed")
    return jsonify({
        "version": APP_VERSION
    })

@app.route("/failure")
def failure():
    logger.error("Simulated application failure")
    return jsonify({"error": "simulated failure"}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)  # nosec B104
