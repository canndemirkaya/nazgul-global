Purpose
-------
This document explains the simple JSONL-based storage used to record agent interactions and choices.

Location
--------
- Default events file: `work/agent_events.jsonl`

Per-session files
-----------------
To avoid mixing different conversations, we support per-session files under `work/events/{session_id}.jsonl`.
Create a session with `create_session(session_id, metadata)` which also writes an index record to `work/sessions.jsonl`.

Index
-----
`work/sessions.jsonl` contains one JSON object per session with `session_id`, `ts` and optional metadata.

Schema
------
Each line is a JSON object. Example fields:

 - `id`: uuid string (generated if missing)
 - `ts`: ISO8601 UTC timestamp
 - `workflow_id`: optional workflow identifier
 - `step`: step name
 - `from`: agent who asked
 - `to`: agent who received
 - `question`: the prompt or question text
 - `choices`: optional list
 - `selected`: the chosen value

Usage
-----
CLI quick checks:

```powershell
python scripts/storage.py --check
python scripts/storage.py --append '{"workflow_id":"w1","step":"ask","from":"A","to":"B","question":"pick"}'
```

Notes
-----
- Append-only JSONL gives easy auditability and integration with file-based toolchains.
- Implemented rotation via `Storage.rotate(max_bytes=...)`.
- Migration path: write migration script to load JSONL into SQLite/Postgres when needed.

Examples
--------
Create a session and append an event:

```powershell
python scripts/storage.py --create-session mysession
python scripts/storage.py --session mysession --append '{"workflow_id":"w1","step":"ask","from":"A","to":"B","question":"pick"}'
```
