# ADR-001: Native SwiftUI and Vapor Architecture

Status: Accepted
Date: 2026-11-02

## Context

Lurewake is a native deception-assurance platform.

The system needs to deploy authorized digital lures,
observe real interactions, preserve evidence, and
validate detection pipeline stages.

The mobile application must not be the authoritative
source of detection events.

## Decision

I will use:

- SwiftUI for the native iOS application.
- Swift Vapor 4 for the backend API.
- PostgreSQL for durable backend storage.
- Docker Compose for reproducible local infrastructure.
- Swift Package Manager for backend dependencies.
- GitHub SSH and pull requests for development.

## Responsibilities

The iOS client manages workflows and presents evidence.

The backend owns authorization, lure lifecycle management,
event collection, correlation, and validation results.

The database will preserve backend records once implemented.

## Rationale

Using Swift across the client and backend allows me
to develop a cohesive native security product while
demonstrating both mobile and server engineering.

The backend operates independently of the iPhone,
allowing event collection when the app is closed.

## Tradeoffs

- A native iOS application requires Apple development tooling.
- Vapor has a smaller ecosystem than some server frameworks.
- Operating the backend adds infrastructure complexity.
- Push notifications and physical NFC require separate testing.

## Current implementation

Completed:
- Native SwiftUI foundation
- Branded development screen
- Vapor application bootstrap
- GET /health endpoint
- Initial automated backend test

Not yet implemented:
- PostgreSQL persistence
- Authentication and authorization
- Lure issuance and event collection
- Detection validation and evidence exports
