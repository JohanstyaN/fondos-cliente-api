import httpx
_orig_init = httpx.Client.__init__
def _patched_init(self, *args, **kwargs):
    kwargs.pop("app", None)
    return _orig_init(self, *args, **kwargs)
httpx.Client.__init__ = _patched_init

import sys, types
sys.modules["email_validator"] = types.ModuleType("email_validator")

import pytest
from fastapi.testclient import TestClient
from datetime import datetime, timezone

from app.main import app
import app.routers.funds as router

def fake_create_transaction(user_id, id_fund, transaction_type, notification_type=None):
    return {
        "transaction_id": "fake-tx-id",
        "user_id": user_id,
        "id_fund": id_fund,
        "transaction_type": transaction_type,
        "new_balance": 123.45,
        "timestamp": datetime(2025, 5, 3, 0, 0, tzinfo=timezone.utc)
    }

@pytest.fixture(autouse=True)
def stub_router_tx(monkeypatch):
    monkeypatch.setattr(router, "create_transaction", fake_create_transaction)

client = TestClient(app)


def test_health_check():
    r = client.get("/v1/funds/health")
    assert r.status_code == 200
    assert r.json() == {"status": "ok"}


def test_subscribe_success():
    payload = {
        "user_id": "u1",
        "id_fund": "F123",
        "transaction_type": "subscribe",
        "notification_type": "email"
    }
    r = client.post("/v1/funds/subscribe", json=payload)
    assert r.status_code == 200
    data = r.json()
    assert data["transaction_id"] == "fake-tx-id"
    assert data["user_id"] == "u1"
    assert data["id_fund"] == "F123"
    assert data["transaction_type"] == "subscribe"
    assert isinstance(data["new_balance"], float)
    assert data["timestamp"].startswith("2025-05-03T00:00:00")


def test_subscribe_invalid_type():
    payload = {
        "user_id": "u1",
        "id_fund": "F123",
        "transaction_type": "cancel",
        "notification_type": "email"
    }
    r = client.post("/v1/funds/subscribe", json=payload)
    assert r.status_code == 400
    assert "Invalid transaction type" in r.json()["detail"]


def test_cancel_success():
    payload = {
        "user_id": "u1",
        "id_fund": "F123",
        "transaction_type": "cancel"
    }
    r = client.post("/v1/funds/cancel", json=payload)
    assert r.status_code == 200
    data = r.json()
    assert data["transaction_id"] == "fake-tx-id"
    assert data["transaction_type"] == "cancel"


def test_cancel_invalid_type():
    payload = {
        "user_id": "u1",
        "id_fund": "F123",
        "transaction_type": "subscribe"
    }
    r = client.post("/v1/funds/cancel", json=payload)
    assert r.status_code == 400
    assert "Invalid transaction type" in r.json()["detail"]
