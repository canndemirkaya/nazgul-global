import threading
import time
import json
from http.client import HTTPConnection
from http.server import ThreadingHTTPServer
from scripts.status_server import Handler, DEFAULT_HOST

def _start_server(port):
    server = ThreadingHTTPServer((DEFAULT_HOST, port), Handler)
    t = threading.Thread(target=server.serve_forever, daemon=True)
    t.start()
    return server, t

def test_status_endpoints(tmp_path, monkeypatch):
    # run server on ephemeral port
    import socket
    sock = socket.socket()
    sock.bind((DEFAULT_HOST, 0))
    port = sock.getsockname()[1]
    sock.close()

    monkeypatch.chdir(tmp_path)
    server, _ = _start_server(port)
    time.sleep(0.1)
    conn = HTTPConnection(f"{DEFAULT_HOST}", port, timeout=5)
    # create a session first by touching file
    from scripts.storage import create_session
    create_session("ts1", {"meta":"x"})
    conn.request("GET", "/status/test-agent?session=ts1")
    resp = conn.getresponse()
    assert resp.status == 200
    data = json.loads(resp.read().decode("utf-8"))
    assert data.get("status") == "ok"
    # post event
    headers = {"Content-Type":"application/json"}
    conn.request("POST", "/event?session=ts1", body=json.dumps({"foo":"bar"}), headers=headers)
    resp2 = conn.getresponse()
    assert resp2.status == 200
    server.shutdown()
