-
---
title: Khamul Proposal Examples
description: Example proposals and machine-applicable patches for Khamul to use as references.
author: nazgul
---

# Khamul proposal examples (machine-ready)

Example 1 — Add status endpoint for Service Z
- Title: Add status endpoint for Service Z
- Summary: Adds a lightweight GET /api/z/status endpoint returning JSON {"status":"ok"} for monitoring and health checks. Non-breaking.
- Impact: backend: src/ServiceZ/Controllers/StatusController.cs; tests: src/ServiceZ.Tests/StatusTests.cs
- BreakingChange: false
- DataLossRisk: none
- PreferredImplementer: morgul
- Patch (unified diff):
--- a/src/ServiceZ/Controllers/StatusController.cs
+++ b/src/ServiceZ/Controllers/StatusController.cs
@@
+using Microsoft.AspNetCore.Mvc;

+namespace ServiceZ.Controllers
+{
+    [ApiController]
+    [Route("api/z")]
+    public class StatusController : ControllerBase
+    {
+        [HttpGet("status")]
+        public IActionResult Get() => Ok(new { status = "ok" });
+    }
+}

- Validation:
  - `dotnet test ./src/ServiceZ.Tests` -> exit code 0
  - Start the service and `curl -s http://localhost:5000/api/z/status` -> `{"status":"ok"}`
- EstimatedEffort: 2h
- RollbackPlan: revert commit that adds StatusController.cs

---

Example 2 — Add StatusCard component to web UI
- Title: Add StatusCard component and route
- Summary: Add a small `StatusCard` React component and a `/status` route that fetches `/api/z/status` and displays the status. Non-breaking frontend-only change.
- Impact: frontend: web/src/components/StatusCard.jsx; web/src/App.jsx
- BreakingChange: false
- DataLossRisk: none
- PreferredImplementer: akhorahil
- Patch (unified diff):
--- a/web/src/components/StatusCard.jsx
+++ b/web/src/components/StatusCard.jsx
@@
+import React, { useEffect, useState } from 'react';

+export default function StatusCard(){
+  const [status, setStatus] = useState('loading');
+  useEffect(()=>{ fetch('/api/z/status').then(r=>r.json()).then(j=>setStatus(j.status)).catch(()=>setStatus('error')) },[])
+  return (
+    <div className="status-card">
+      <h3>Service Z</h3>
+      <p>Status: {status}</p>
+    </div>
+  )
+}

--- a/web/src/App.jsx
+++ b/web/src/App.jsx
@@
+import StatusCard from './components/StatusCard';
@@
+  <Route path="/status" element={<StatusCard/>} />

- Validation:
  - `npm --prefix web install` -> exit code 0
  - `npm --prefix web run build` -> exit code 0
  - Visit `/status` route in dev server and verify page shows `Status: ok` when backend is running
- EstimatedEffort: 2h
- RollbackPlan: revert commit(s) adding StatusCard and App route

---

Example 3 — Migrate legacy `users_legacy` table to `users` schema (DESCTRUCTIVE)
- Title: Migrate and drop legacy users_legacy table
- Summary: Run a one-time migration to copy selected columns from `users_legacy` into `users`, transform data, and then drop the legacy table. This is potentially data-destructive and requires backups and a rollback plan.
- Impact: backend/db: migrations/2026-05-06_migrate_users.sql; may require downtime. Also update data-access code in src/ServiceZ/Data/UserRepository.cs
- BreakingChange: true
- DataLossRisk: high
- PreferredImplementer: morgul (requires DBA oversight)
- Options:
  - Safe path: create new columns in `users`, copy rows, verify checksums, switch reads to `users`, then drop `users_legacy` after a 7-day retention. (Recommended)
  - Fast path: copy and drop immediately (NOT recommended)
- Patch (migration SQL):
--- a/migrations/2026-05-06_migrate_users.sql
+++ b/migrations/2026-05-06_migrate_users.sql
@@
+-- WARNING: run only after backup; this migration is destructive
+BEGIN TRANSACTION;
+
+-- create new columns if missing
+ALTER TABLE users ADD COLUMN legacy_source_id bigint NULL;

+-- copy data with transformations
+INSERT INTO users (id, email, name, legacy_source_id)
+SELECT id, LOWER(email), CONCAT(first_name,' ',last_name), id FROM users_legacy WHERE email IS NOT NULL;

+-- verification step (manual): compare counts/checksums before committing
+
-- DROP TABLE users_legacy; -- run only after verification and retention window
+
COMMIT;

- Validation:
  - Ensure full DB backup exists before running migration
  - Run checksums: `SELECT COUNT(*) FROM users_legacy; SELECT COUNT(*) FROM users WHERE legacy_source_id IS NOT NULL;` and compare
  - Run application integration smoke tests: `dotnet test ./src/ServiceZ.Tests` -> exit 0
- EstimatedEffort: 1d (analysis + testing + runbook)
- RollbackPlan: restore DB from backup snapshot taken immediately before migration; do NOT run migration on production without approval
- Escalation: ESCALATE_TO_USER — this is a breaking/data-loss operation and requires explicit user approval before scheduling or execution.
