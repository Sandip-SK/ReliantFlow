from app.main import app


def test_home():
    client = app.test_client()

    response = client.get("/")

    assert response.status_code == 200
    assert response.json["service"] == "ReliantFlow"
    assert response.json["status"] == "healthy"


def test_admin():
    client = app.test_client()

    response = client.get("/admin")

    assert response.status_code == 200
    assert response.json["message"] == "admin endpoint"


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


def test_health():
    client = app.test_client()

    response = client.get("/health")

    assert response.status_code == 200
    assert response.json["status"] == "healthy"


def test_version():
    client = app.test_client()

    response = client.get("/version")

    assert response.status_code == 200
    assert response.json["version"] == "1.0.0"


def test_invalid_endpoint():
    client = app.test_client()

    response = client.get("/does-not-exist")

    assert response.status_code == 404