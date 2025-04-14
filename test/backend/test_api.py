import pytest
from backend.api.app import app
import json

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_health_check(client):
    """Test the health check endpoint."""
    response = client.get('/health')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert 'status' in data

def test_index_route(client):
    """Test the index route."""
    response = client.get('/')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['name'] == 'Social Media Analytics API'
    assert 'version' in data
    assert 'endpoints' in data

def test_analytics_sentiment(client):
    """Test the sentiment analysis endpoint."""
    response = client.get('/api/analytics/sentiment')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert 'status' in data

def test_analytics_topics(client):
    """Test the topic analysis endpoint."""
    response = client.get('/api/analytics/topics')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert 'status' in data 