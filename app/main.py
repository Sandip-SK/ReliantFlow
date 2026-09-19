from flask import Flask, jsonify, request

app = Flask(__name__)

@app.route("/admin")
def admin():
    return jsonify({
        "message": "admin endpoint"
    })


@app.route("/")
def home():
    return jsonify({
        "service": "ReliantFlow",
        "status": "healthy"
    })


@app.route("/calculate")
def calculate():
    value = int(request.args.get("value", 10))

    if value > 100:
        return jsonify({"result": "high"})

    if value < 0:
        return jsonify({"result": "negative"})

    if value == 10:
        return jsonify({"result": "exact"})

    return jsonify({"result": "normal"})


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy"
    })


@app.route("/version")
def version():
    return jsonify({
        "version": "1.0.0"
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)  # nosec B104