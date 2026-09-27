from app.main import app

def test_ready():
    client = app.test_client()

    response = client.get("/ready")

    assert response.status_code == 200
    assert response.json["status"] == "ready"


def test_health():
    client = app.test_client()

    response = client.get("/health")

    assert response.status_code == 200
    assert response.json["status"] == "healthy"


def test_failure():
    client = app.test_client()

    response = client.get("/failure")

    assert response.status_code == 500
    assert response.json["error"] == "simulated failure"


def test_calculate_high():
    client = app.test_client()

    response = client.get("/calculate?value=150")

    assert response.status_code == 200
    assert response.json["result"] == "high"


def test_calculate_negative():
    client = app.test_client()

    response = client.get("/calculate?value=-5")

    assert response.status_code == 200
    assert response.json["result"] == "negative"


def test_calculate_exact():
    client = app.test_client()

    response = client.get("/calculate?value=10")

    assert response.status_code == 200
    assert response.json["result"] == "exact"


def test_calculate_normal():
    client = app.test_client()

    response = client.get("/calculate?value=50")

    assert response.status_code == 200
    assert response.json["result"] == "normal"


def test_calculate_default():
    client = app.test_client()

    response = client.get("/calculate")

    assert response.status_code == 200
    assert response.json["result"] == "exact"


def test_version():
    client = app.test_client()

    response = client.get("/version")

    assert response.status_code == 200
    assert "version" in response.json