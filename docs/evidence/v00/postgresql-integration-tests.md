# V0.0 — Automated PostgreSQL Integration Testing

Date: 2026-11-02
Branch: feat/v00-foundation

## Objective

Verify persisted lure inventory records through
the real Fluent database layer and Vapor API.

## Test Architecture

Production development database: lurewake
Isolated integration database: lurewake_test

Both databases run in local Docker PostgreSQL.

The integration test explicitly connects to
lurewake_test instead of the development database.

## Verified Results

- Backend build: PASS
- Health endpoint test: PASS
- Inventory response encoding test: PASS
- PostgreSQL integration test: PASS
- Total opt-in automated tests: 3
- Failed tests: 0
- Integration test exit code: 0
- Test fixture cleanup: PASS
- Normal test suite without DB credentials: PASS

## Integration Coverage

The automated integration test:

1. Configures a dedicated PostgreSQL test connection.
2. Applies the Fluent CreateLures migration.
3. Inserts a uniquely named draft lure.
4. Calls GET /api/v1/lures.
5. Verifies the saved lure ID, name, kind, and status.
6. Deletes the test fixture.
7. Queries the endpoint again to verify removal.

## Run the Tests

Normal backend tests:

    swift test --package-path services/api

Database integration tests:

    (
        set -a
        source .env
        export LUREWAKE_RUN_DB_TESTS=1
        set +a
        swift test --package-path services/api
    )

## Security Boundaries

Database integration testing is opt-in.

Test records are not issued or deployed lures.

No real detection events were created.

Authentication, event ingestion, and detection
validation remain future milestones.

The integration test requires local PostgreSQL
and is not yet part of GitHub CI.
