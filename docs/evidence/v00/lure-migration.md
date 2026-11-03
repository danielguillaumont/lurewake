# V0.0 — First Persistent Lure Model

Date: 2026-11-02
Branch: feat/v00-foundation

## Objective

Establish the first versioned PostgreSQL schema
for the Lurewake deception-assurance platform.

## Implementation

Created the Lure Fluent model and CreateLures migration.

Model:
services/api/Sources/LurewakeAPI/Models/Lure.swift

Migration:
services/api/Sources/LurewakeAPI/Migrations/CreateLures.swift

The model uses an explicit @unchecked Sendable conformance
for compatibility with Swift 6 and Fluent's mutable models.

## Verified Results

- Swift backend build: PASS
- Automated backend tests: 1 passed, 0 failed
- PostgreSQL container: healthy
- CreateLures migration: successful
- Migration command exit code: 0
- PostgreSQL lures table: exists
- Primary key: UUID
- Initial lure count: 0

## Database Schema

| Column | Type | Required |
| --- | --- | --- |
| id | UUID | Yes |
| name | Text | Yes |
| kind | Text | Yes |
| status | Text | Yes |
| notes | Text | No |
| created_at | Timestamp | No |
| updated_at | Timestamp | No |

## Architecture Validation

Fluent migrations define and apply the database schema.

PostgreSQL maintains persistent application records
independently of the native iOS application.

The migration is tracked by Fluent and can be
reproduced on a fresh development database.

## Limitations

No lure inventory API or issuance workflow exists yet.

No actual lures have been deployed or activated.

The current automated test covers API health,
not migration behavior or database CRUD operations.

Authentication, authorization, lifecycle validation,
and event ingestion remain future work.

## Next Step

Implement the first database-backed lure inventory API,
including read-only listing and automated API tests.
