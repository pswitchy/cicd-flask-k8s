import pytest
from app.app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_home_endpoint(client):
    """Test the main endpoint."""
    rv = client.get('/')
    assert rv.status_code == 200
    assert b"Hello, DevOps World!" in rv.data

def test_health_check_endpoint(client):
    """Test the health check endpoint."""
    rv = client.get('/health')
    assert rv.status_code == 200
    assert b"healthy" in rv.data