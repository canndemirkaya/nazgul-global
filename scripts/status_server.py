#!/usr/bin/env python3
"""Minimal status HTTP server.

Endpoints:
- GET /status/{agent}?session={session_id}  -> returns health JSON and writes a health event to the session file if session provided
- POST /event?session={session_id} with JSON body -> append arbitrary event to session

Default listen port: 54337 (configurable via --port)
"""
import argparse
import json
import time
import threading
from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
from scripts.storage import open_session, read_sessions

# Configuration (set in code, not via CLI)
DEFAULT_HOST = "127.0.0.1"
DEFAULT_PORT = 54337
DEFAULT_SWEEP_INTERVAL = 300  # seconds; change in code if desired


class Handler(BaseHTTPRequestHandler):
    def _send_json(self, code: int, obj: dict):
        data = json.dumps(obj, ensure_ascii=False).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def log_message(self, format, *args):
        # keep logs minimal
        print("[status_server] %s - %s" % (self.address_string(), format % args))

    def do_GET(self):
        p = urlparse(self.path)
        parts = p.path.strip("/").split("/")
        qs = {k: v[0] for k, v in parse_qs(p.query).items()}

        if len(parts) >= 2 and parts[0] == "status":
            agent = parts[1]
            resp = {"name": agent, "status": "ok", "ts": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())}
            session = qs.get("session")
            if session:
                try:
                    store = open_session(session)
                    ev = {"type": "health", "agent": agent, "status": "ok", "ts": resp["ts"]}
                    store.write_event(ev)
                except Exception as e:
                    self._send_json(500, {"error": "failed to write session event", "detail": str(e)})
                    return
            self._send_json(200, resp)
            return

        # not found
        self._send_json(404, {"error": "not found"})

    def do_POST(self):
        p = urlparse(self.path)
        parts = p.path.strip("/").split("/")
        qs = {k: v[0] for k, v in parse_qs(p.query).items()}

        if len(parts) >= 1 and parts[0] == "event":
            session = qs.get("session")
            if not session:
                self._send_json(400, {"error": "missing session query parameter"})
                return
            length = int(self.headers.get("Content-Length", "0"))
            body = self.rfile.read(length) if length else b""
            try:
                payload = json.loads(body.decode("utf-8")) if body else {}
            except Exception:
                self._send_json(400, {"error": "invalid json body"})
                return
            try:
                store = open_session(session)
                w = store.write_event(payload)
                self._send_json(200, w)
            except Exception as e:
                self._send_json(500, {"error": "failed to write event", "detail": str(e)})
            return

        if len(parts) >= 1 and parts[0] == "trigger-health":
            # POST /trigger-health with optional JSON body: {"agent":"name","session":"id"}
            length = int(self.headers.get("Content-Length", "0"))
            body = self.rfile.read(length) if length else b""
            try:
                payload = json.loads(body.decode("utf-8")) if body else {}
            except Exception:
                self._send_json(400, {"error": "invalid json body"})
                return
            agent = payload.get("agent", "monitor")
            session = payload.get("session")
            count = 0
            try:
                if session:
                    store = open_session(session)
                    ev = {"type": "health_check", "agent": agent, "status": "ok", "ts": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())}
                    store.write_event(ev)
                    count = 1
                else:
                    # sweep all sessions in index
                    for s in read_sessions():
                        sid = s.get("session_id")
                        if not sid:
                            continue
                        store = open_session(sid)
                        ev = {"type": "health_check", "agent": agent, "status": "ok", "ts": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())}
                        store.write_event(ev)
                        count += 1
                self._send_json(200, {"written": count})
            except Exception as e:
                self._send_json(500, {"error": "failed to write events", "detail": str(e)})
            return

        self._send_json(404, {"error": "not found"})


def run(host: str = "127.0.0.1", port: int = 54337):
    stop_event = threading.Event()

    def sweep_loop():
        while not stop_event.is_set():
            try:
                # by default, trigger health sweep for all sessions
                for s in read_sessions():
                    sid = s.get("session_id")
                    if not sid:
                        continue
                    try:
                        store = open_session(sid)
                        ev = {"type": "health_check", "agent": "monitor", "status": "ok", "ts": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())}
                        store.write_event(ev)
                    except Exception:
                        pass
            except Exception:
                pass
            stop_event.wait(DEFAULT_SWEEP_INTERVAL)

    server = ThreadingHTTPServer((host, port), Handler)
    t = threading.Thread(target=sweep_loop, daemon=True)
    t.start()
    print(f"status_server listening on http://{host}:{port} (sweep_interval={DEFAULT_SWEEP_INTERVAL}s)")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("shutting down")
        stop_event.set()
        server.shutdown()


if __name__ == "__main__":
    # Port/host configured in code constants above. Run with defaults.
    run(DEFAULT_HOST, DEFAULT_PORT)
