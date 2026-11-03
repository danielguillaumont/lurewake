# Lurewake Development Environment

Baseline recorded: November 2, 2026

## Development machine

- Machine: MacBook Air
- Architecture: Apple Silicon / arm64
- macOS: 26.6.2
- Xcode: 26.2 (17C52)
- Swift: 6.2.3
- Git: 2.50.1

## iOS testing

- Simulator runtime: iOS 26.2
- Primary planned simulator: iPhone 17 Pro

## Backend

- Framework: Vapor 4 (implemented; version 4.122.2)
- Database: PostgreSQL (planned)
- Docker: Docker Desktop 4.97.0; Engine 29.9.2; Compose v5.6.1 (verified)

## Repository

- Location: ~/Documents/Personal Projects/lurewake
- Git transport: SSH
- GitHub account: danielguillaumont

## Notes

This repository is isolated from Sheridan coursework and other projects.

The environment baseline records installed tools, not completed application functionality.

## Verified application foundation

- iOS Xcode project: apps/LurewakeIOS/Lurewake/Lurewake.xcodeproj
- iOS simulator: iPhone 17 Pro / iOS 26.2
- Vapor package: services/api
- Vapor dependency: 4.122.2
- Backend health endpoint: GET /health
- Local API: http://127.0.0.1:8080
- Backend build: successful
- Backend automated tests: 1 passed
- HTTP smoke test: 200 OK

## Current limitations

The backend health route is a basic liveness check.
No database, authentication, lure issuance, event ingestion,
or detection validation has been implemented yet.
