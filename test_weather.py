import pytest
import requests

@pytest.fixture
def is_website_reachable():
    url = "http://localhost:5000"
    response = requests.get(url)
    return response.status_code == 200

def test_website_reachable(is_website_reachable):
    assert is_website_reachable