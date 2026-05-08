import os
import tempfile
import json
from scripts import storage


def test_session_create_and_append():
    # use a temp work dir by overriding paths
    tmpdir = tempfile.mkdtemp(prefix="agent_work_")
    try:
        # patch functions to use tmpdir
        orig_index = storage.index_path
        orig_session_path = storage.session_path

        storage.index_path = lambda: os.path.join(tmpdir, "sessions.jsonl")
        storage.session_path = lambda sid: os.path.join(tmpdir, "events", f"{sid}.jsonl")

        sid = "s1"
        meta = storage.create_session(sid, {"owner": "tester"})
        assert meta["session_id"] == sid
        # append an event to session
        ss = storage.open_session(sid)
        ev = {"workflow_id": "w1", "step": "ask", "from": "A", "to": "B", "question": "q"}
        written = ss.write_event(ev)
        assert "id" in written and "ts" in written
        # read back
        events = list(ss.read_events())
        assert len(events) == 1
        assert events[0]["question"] == "q"
    finally:
        # restore
        storage.index_path = orig_index
        storage.session_path = orig_session_path
        try:
            # cleanup tmpdir
            import shutil

            shutil.rmtree(tmpdir)
        except Exception:
            pass
