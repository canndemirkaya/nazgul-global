import tempfile
import os
from scripts.storage import Storage, create_session, read_sessions, session_path

def test_storage_write_and_read(tmp_path):
    p = tmp_path / "events.jsonl"
    s = Storage(str(p))
    ev = s.write_event({"type": "test", "value": 1})
    assert "id" in ev and "ts" in ev
    items = list(s.read_events())
    assert any(i.get("type") == "test" for i in items)

def test_session_index_and_create(tmp_path, monkeypatch):
    monkeypatch.chdir(tmp_path)
    meta = create_session("s1", {"owner":"tester"})
    assert meta.get("session_id") == "s1"
    idx = list(read_sessions())
    assert any(i.get("session_id") == "s1" for i in idx)
    sp = session_path("s1")
    assert sp.exists()
