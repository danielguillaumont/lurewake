# v0.1 — Protected Draft Creation Verification

Date: 2026-11-03
Branch: feat/v01-lure-lifecycle

## Scope

Implemented authenticated, validated creation of
draft lure records through the Vapor API.

Endpoint: POST /api/v1/lures

## Verified HTTP Results

| Scenario | Expected | Result |
| --- | --- | --- |
| Missing credentials | 401 | PASS |
| Incorrect credentials | 401 | PASS |
| Invalid draft metadata | 400 | PASS |
| Authorized draft creation | 201 | PASS |
| Created record appears in inventory | 200 | PASS |

## Persistence Evidence

Test record: LW-V01-SMOKE-C0452F

The endpoint returned a UUID, kind "document",
and lifecycle status "draft".

A subsequent GET /api/v1/lures returned the
created record from PostgreSQL.

The smoke-test record remains in the local
development database for UI verification.

## Automated Verification

- Backend build: PASS
- Normal suite: 19 passed, 1 skipped, 0 failed
- Full PostgreSQL suite: 20 passed, 0 skipped, 0 failed
  (record only after confirming the full suite passes)

## Security Boundaries

The POST endpoint requires a local operator
bearer credential loaded from Git-ignored .env.

Credentials are not committed to GitHub.

The API currently uses a development-only
single-operator authentication model.

It must not be exposed over an unprotected
network or treated as production-ready.

The read-only inventory route remains accessible
without operator authentication.

No lure is deployed, and no interaction detection
or evidence collection is implemented yet.

## Next Checkpoint

Add database-backed integration tests for
authenticated creation, rejection and cleanup.
