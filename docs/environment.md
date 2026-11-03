# Lurewake Development Environment

Baseline recorded: 2026-11-02
Updated for: v0.0 foundation acceptance review

## Development machine

- Machine: Apple Silicon MacBook Air
- macOS: 26.6.2
- Xcode: 26.2 (17C52)
- Swift: 6.2.3
- Git: 2.50.1
- iOS simulator: iPhone 17 Pro / iOS 26.2

## Backend

- Vapor: 4.122.2
- PostgreSQL: 17-alpine
- Fluent: 4.13.0
- Fluent PostgreSQL driver: 2.12.0
- Docker Desktop: 4.97.0
- Docker Engine: 29.9.2
- Docker Compose: v5.6.1

## Local connectivity

- API: http://127.0.0.1:8080
- PostgreSQL: 127.0.0.1:5433
- Development database: lurewake
- Isolated test database: lurewake_test

The `.env` file contains the local database password and is excluded from Git.

## Implemented functionality

- Native SwiftUI navigation and design system
- Observatory backend liveness display
- PostgreSQL connectivity and readiness check
- Fluent CreateLures migration
- Database-backed read-only lure inventory API
- Native empty, populated, and connection-error states
- Refresh and recovery functionality

## Verified tests

- iOS simulator build: PASS
- Native iPhone 17 Pro launch: PASS
- API build: PASS
- Normal backend suite: 2 passed, 1 skipped
- Opt-in database test suite: 3 passed, 0 failed
- PostgreSQL test fixture cleanup: PASS
- Database-to-iPhone manual smoke test: PASS

These are local verification results, not claims of a successful CI run.

## Security and limitations

- No production authentication or authorization
- No deployed lures or live interaction ingestion
- No validated detections or evidence exports
- Development API is not approved for public exposure
- Further simulator sizes and accessibility testing remain

## Repository

- Local project: ~/Documents/Personal Projects/lurewake
- Git transport: SSH
- Feature branch: feat/v00-foundation
- Evidence directory: docs/evidence/v00
