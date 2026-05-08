import json
import os
import pathlib
import time
import uuid


class Storage:
    """Simple JSONL append-only storage for agent events.

    Default path: work/agent_events.jsonl
    """

    def __init__(self, path: str = "work/agent_events.jsonl"):
        self.path = pathlib.Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)

    def _ensure_event(self, event: dict) -> dict:
        ev = dict(event)
        if "id" not in ev:
            ev["id"] = str(uuid.uuid4())
        if "ts" not in ev:
            ev["ts"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
        return ev

    def write_event(self, event: dict) -> dict:
        """Append an event dict to the JSONL file (atomic as possible).

        Returns the written event (with id/ts filled).
        """
        ev = self._ensure_event(event)
        line = json.dumps(ev, ensure_ascii=False)
        # Open, append, flush and fsync to reduce risk of loss on crash
        with open(self.path, "a", encoding="utf-8") as fh:
            fh.write(line + "\n")
            fh.flush()
            try:
                os.fsync(fh.fileno())
            except Exception:
                pass
        return ev

    def read_events(self):
        """Yield events from the JSONL file in order."""
        if not self.path.exists():
            return
        with open(self.path, "r", encoding="utf-8") as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                try:
                    yield json.loads(line)
                except Exception:
                    continue

    def query_events(self, **filters):
        """Return events where all provided key==value match."""
        for ev in self.read_events():
            ok = True
            for k, v in filters.items():
                if ev.get(k) != v:
                    ok = False
                    break
            if ok:
                yield ev

    def rotate(self, max_bytes: int = 10_000_000):
        """Rotate the file if it exceeds `max_bytes`. Renames current file with timestamp."""
        try:
            size = self.path.stat().st_size
        except Exception:
            return False
        if size <= max_bytes:
            return False
        dst = self.path.with_name(self.path.stem + "-" + time.strftime("%Y%m%dT%H%M%S") + self.path.suffix)
        self.path.rename(dst)
        # Create empty new file
        self.path.write_text("", encoding="utf-8")
        return True


def session_path(session_id: str) -> pathlib.Path:
    p = pathlib.Path("work/events")
    p.mkdir(parents=True, exist_ok=True)
    return p / f"{session_id}.jsonl"


def open_session(session_id: str) -> Storage:
    """Return a Storage instance pointed at a session-specific JSONL file."""
    return Storage(str(session_path(session_id)))


def index_path() -> pathlib.Path:
    p = pathlib.Path("work")
    p.mkdir(parents=True, exist_ok=True)
    return p / "sessions.jsonl"


def create_session(session_id: str, metadata: dict | None = None) -> dict:
    """Create a session index entry in `work/sessions.jsonl` and ensure session file exists.

    Returns the session metadata written.
    """
    meta = {"session_id": session_id}
    if metadata:
        meta.update(metadata)
    if "ts" not in meta:
        meta["ts"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    line = json.dumps(meta, ensure_ascii=False)
    idx = index_path()
    with open(idx, "a", encoding="utf-8") as fh:
        fh.write(line + "\n")
        fh.flush()
        try:
            os.fsync(fh.fileno())
        except Exception:
            pass
    # ensure session file exists
    sp = session_path(session_id)
    if not sp.exists():
        sp.write_text("", encoding="utf-8")
    return meta


def read_sessions():
    """Yield session index entries from `work/sessions.jsonl`."""
    idx = index_path()
    if not idx.exists():
        return
    with open(idx, "r", encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                yield json.loads(line)
            except Exception:
                continue


def _cli():
    import argparse

    p = argparse.ArgumentParser()
    p.add_argument("--path", default="work/agent_events.jsonl")
    p.add_argument("--check", action="store_true")
    p.add_argument("--append", help="JSON string to append as event")
    p.add_argument("--dry", action="store_true")
    args = p.parse_args()

    store = Storage(args.path)
    if args.check:
        print("Path:", store.path)
        print("Exists:", store.path.exists())
        try:
            print("Size:", store.path.stat().st_size)
        except Exception:
            pass
        return

    if args.append:
        ev = json.loads(args.append)
        if args.dry:
            print(json.dumps(store._ensure_event(ev), indent=2, ensure_ascii=False))
        else:
            w = store.write_event(ev)
            print(json.dumps(w, ensure_ascii=False))
    # session helpers
    if hasattr(args, "create_session") and args.create_session:
        meta = create_session(args.create_session, None)
        print(json.dumps(meta, ensure_ascii=False))
    if hasattr(args, "session") and args.session and args.append:
        ss = open_session(args.session)
        ev = json.loads(args.append)
        if args.dry:
            print(json.dumps(ss._ensure_event(ev), indent=2, ensure_ascii=False))
        else:
            w = ss.write_event(ev)
            print(json.dumps(w, ensure_ascii=False))


if __name__ == "__main__":
    _cli()
