import os
import tempfile
import json
from scripts.storage import Storage


def test_write_and_read():
    fd, path = tempfile.mkstemp(prefix="agent_events_", suffix=".jsonl")
    os.close(fd)
    try:
        store = Storage(path)
        ev = {"workflow_id": "w1", "step": "ask_user", "from": "agentA", "to": "agentB", "question": "pick"}
        written = store.write_event(ev)
        assert "id" in written and "ts" in written
        events = list(store.read_events())
        assert len(events) == 1
        loaded = events[0]
        assert loaded["workflow_id"] == "w1"
        assert loaded["question"] == "pick"
    finally:
        try:
            os.remove(path)
        except Exception:
            pass
