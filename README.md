# lurewake

**Plant the lure. Follow the wake. Prove the signal.**

Lurewake is a native Swift deception-assurance platform being built to deploy controlled digital tripwires, observe interactions, validate detection pipelines, and preserve reproducible evidence.

## Development status

**PREP — Foundation**

Implemented:
- Native SwiftUI iPhone application
- Initial nocturnal brand interface
- Swift Vapor 4 backend
- Local GET /health endpoint
- Automated backend health test
- GitHub SSH development workflow

Not yet implemented:
- Live lure issuance
- PostgreSQL persistence
- Authentication and authorization
- Interaction collection
- Proof-of-Detection engine
- QR and NFC deployment

No detection capabilities are claimed as operational.

## Technology

- Swift 6.2.3
- SwiftUI
- Xcode 26.2
- Vapor 4.122.2
- PostgreSQL (planned)
- Docker Compose (installed; database not configured yet)

## Project structure

- apps/LurewakeIOS — Native iPhone application
- services/api — Swift Vapor backend
- docs/environment.md — Development environment
- docs/decisions — Architecture decisions
- docs/evidence — Milestone verification

## Run the iPhone application

From the repository root:

    open apps/LurewakeIOS/Lurewake/Lurewake.xcodeproj

In Xcode, choose the Lurewake scheme and the
iPhone 17 Pro simulator, then press Command + R.

## Run the backend

From the repository root:

    swift build --package-path services/api
    swift test --package-path services/api

Start the API:

    cd services/api
    swift run LurewakeAPI serve

In another Terminal window:

    curl -i http://127.0.0.1:8080/health

Expected HTTP status: 200 OK

The health endpoint confirms server liveness only.
It does not validate detection or database readiness.

## Security boundaries

Lurewake is intended for authorized testing
in controlled environments only.

The project will not harvest credentials, silently
track unrelated visitors, or claim that a decoy
interaction proves malicious activity.

## Documentation

- docs/environment.md
- docs/decisions/ADR-001-architecture.md
- docs/evidence/prep/acceptance.md

## Project status

Planning and early implementation are in progress.
The application is not production-ready.
