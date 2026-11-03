# V0.0 — Read-Only Lure Inventory API

Date: 2026-11-02
Branch: feat/v00-foundation

## Objective

Implement the first database-backed Lurewake
inventory endpoint using Vapor, Fluent, and PostgreSQL.

## Endpoint

GET /api/v1/lures

## Verified Live Responses

- GET /health: HTTP 200 OK
- GET /ready: HTTP 200 OK
- GET /api/v1/lures: HTTP 200 OK

## Inventory Response

{"items":[],"returnedCount":0,"limit":100}

The inventory is currently empty because no lure
records have been created.

## Implementation

The route queries PostgreSQL through Fluent.

Records are ordered by name and limited to
100 returned items.

The response contains only selected fields:
ID, name, kind, status, and creation timestamp.

Internal lure notes are not exposed.

## Security Boundaries

This is a local development endpoint.

No lure creation, issuance, activation, or
deployment capability has been implemented.

Authentication and authorization are still pending.
The inventory API must not be publicly exposed
until appropriate access controls are implemented.

## Limitations

The empty-inventory behavior has been verified
against the running database.

Nonempty inventory, pagination, and database
integration tests remain to be implemented.

## Next Step

Connect the native SwiftUI Lures tab to this API
and verify a real empty inventory state.
