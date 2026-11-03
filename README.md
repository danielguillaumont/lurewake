# Lurewake

**Plant the lure. Follow the wake. Prove the signal.**

Lurewake is a native Swift deception-assurance project designed to help security teams deploy authorized digital lures, observe real interactions, and eventually verify whether their detection pipelines respond.

The goal is to make deception testing observable, reproducible, and evidence-driven.

## Development status — v0.0 Foundation

The v0.0 milestone establishes a working native client, independent backend, and persistent lure inventory.

### Implemented

- Native SwiftUI iPhone application
- Four-tab navigation: Overview, Lures, Activity, Proof
- Reusable nocturnal design system
- Live Observatory connection status
- Vapor 4 backend with PostgreSQL and Fluent
- Docker Compose local database
- Versioned `CreateLures` database migration
- `GET /health` — API liveness
- `GET /ready` — PostgreSQL readiness
- `GET /api/v1/lures` — read-only lure inventory
- Loading, empty, populated, and offline inventory states
- Manual refresh and connection recovery
- Automated backend tests and isolated PostgreSQL integration testing
- Screenshot-based development evidence

### Not yet implemented

- Authenticated lure creation and issuance
- Production authentication and authorization
- Deployment of live digital lures
- Interaction/event collection
- Detection pipeline validation
- Evidence chain and export workflows
- QR/NFC deployment
- Production hosting and monitoring

No operational detection capability is claimed at v0.0.

## Screenshots

| Observatory | Empty inventory | Draft inventory |
|:--:|:--:|:--:|
| <img src="docs/evidence/v00/observatory-online.png" width="240"> | <img src="docs/evidence/v00/lures-empty-layout-refinement.png" width="240"> | <img src="docs/evidence/v00/lures-inventory-draft-test.png" width="240"> |

The draft inventory screenshot shows a temporary development test fixture, not an issued or deployed lure.

## Technology

| Component | Technology |
|---|---|
| Native client | SwiftUI, Swift 6.2.3 |
| iOS tooling | Xcode 26.2, iOS 26.2 simulator |
| Backend | Vapor 4.122.2 |
| Persistence | PostgreSQL 17, Fluent |
| Local infrastructure | Docker Compose |
| Automated tests | Swift Testing, VaporTesting |
| Source control | GitHub, SSH, feature branches and pull requests |

## Repository structure

- `apps/LurewakeIOS` — Native iOS application
- `services/api` — Swift Vapor backend
- `compose.yaml` — Local PostgreSQL service
- `docs/decisions` — Architecture decisions
- `docs/evidence/prep` — Completed PREP evidence
- `docs/evidence/v00` — Foundation verification and screenshots
- `.github/workflows` — GitHub Actions

## Local development

The current development environment is an Apple Silicon MacBook Air.

From the repository root, start PostgreSQL:

    docker compose up -d --wait db

The local database password is stored in the Git-ignored `.env` file. Use `.env.example` to see the required variable name, but do not commit an actual password.

Start Vapor with the local credentials loaded:

    (
        set -a
        source .env
        set +a
        swift run --package-path services/api LurewakeAPI serve
    )

The Vapor server runs at:

    http://127.0.0.1:8080

Check the endpoints from a second Terminal:

    curl -i http://127.0.0.1:8080/health
    curl -i http://127.0.0.1:8080/ready
    curl -i http://127.0.0.1:8080/api/v1/lures

The inventory endpoint requires an initialized database schema. The `CreateLures` migration and its local verification are documented in `docs/evidence/v00/lure-migration.md`.

Open the iPhone project:

    open apps/LurewakeIOS/Lurewake/Lurewake.xcodeproj

Select the Lurewake scheme and iPhone 17 Pro simulator, then run with Command + R.

The simulator uses the Mac's local loopback API. A physical iPhone requires separate networking and security configuration.

## Tests

Build the backend:

    swift build --package-path services/api

Run ordinary backend tests:

    swift test --package-path services/api

Expected local baseline: two passing tests and one skipped database integration test.

The PostgreSQL integration test is opt-in and uses the dedicated `lurewake_test` database. After creating that database, run:

    (
        set -a
        source .env
        export LUREWAKE_RUN_DB_TESTS=1
        set +a
        swift test --package-path services/api
    )

The previously verified local integration run passed all three tests.

## Security boundaries

Lurewake is intended for authorized testing in controlled environments only.

At v0.0:

- The local inventory interface is read-only.
- Development database and API access are intended for local use.
- Database credentials must not enter source control.
- Draft records are not deployed lures.
- An empty inventory is not evidence of a healthy detection system.
- No real alerts, interactions, or detection results are generated.

Authentication, HTTPS deployment, authorization, rate limiting, and production operational controls remain future work. Do not expose the development API publicly.

## Evidence and roadmap

See `docs/evidence/v00` for migration, connectivity, automated testing, iOS integration, and screenshot evidence.

Next milestone: v0.1 — controlled draft-lure lifecycle and secure backend workflows.

**Status: development prototype, not production-ready.**
