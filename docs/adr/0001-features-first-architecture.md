# 1. Feature-first architecture with three layers

Date: 2026-10-30

## Status

Accepted

## Context

The app will be used by a real team and must be maintained and extended
over time. Features will be added gradually (calendar, availability,
call-ups, statistics), and the backend may change in the future
(for example, from Firebase to a custom API).

We need a structure that keeps responsibilities separated, makes the code
easy to test and lets each feature evolve independently.

## Decision

The code is organized by feature under `lib/features/`
(for example `events`, `auth`, `team`, `availability`).

Each feature is split into three layers:

- `domain`: entities, repository interfaces and business rules.
  Pure Dart, with no dependency on Flutter or Firebase.
- `data`: data sources, DTOs and repository implementations.
- `presentation`: screens, widgets and state management.

Dependencies follow one rule: presentation → domain ← data.
The UI never talks to the database directly.

Use cases are added only where there is real business logic
(for example, suspensions after cards), not as simple pass-through classes.

## Consequences

- The business logic can be tested without Flutter or Firebase.
- The backend can be replaced by rewriting only the `data` layer.
- Each feature can be developed and reviewed in isolation.
- There are more files and folders than in a simple app,
  which adds some overhead for small features.