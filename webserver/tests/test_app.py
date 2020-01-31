import os
import pytest
import webserver.app as app

@pytest.fixture
def client():
    app.app.config['TESTING'] = True

    return app.app.test_client()
    
def test_get(client):
    rv = client.get('/hello')
    assert b'Hello World from BenchSci' in rv.data