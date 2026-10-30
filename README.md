# Squadra CSI

![CI](https://github.com/lucacoronaa/squadra_csi/actions/workflows/ci.yml/badge.svg)

Squadra CSI is a mobile app to organize and manage an amateur football team
in the CSI (Centro Sportivo Italiano) league. There is no club staff:
the coach is also a player, and the team organizes everything together.
The app helps them plan matches and trainings and keep track of everything
that needs to be done.

## Features

Planned for the first release (MVP):

- Match and training calendar
- Player availability for each event (yes / no / maybe)
- Squad call-ups published by the coach
- Team invitations with a code

Planned for later:

- Push notifications
- Results, goals and assists
- Yellow and red cards with suspension alerts
- Season statistics

## Tech stack

- Flutter and Dart
- Firebase (planned): Authentication, Cloud Firestore, Cloud Messaging
- GitHub Actions for continuous integration

## Architecture

The code is organized by feature (events, auth, team, availability).
Each feature is split into three layers:

- **domain**: entities and business rules, written in pure Dart
- **data**: data sources and repository implementations
- **presentation**: screens and widgets

Dependencies point towards the domain: the presentation and data layers
depend on it, while the domain depends on neither Flutter nor Firebase.
This keeps the business logic easy to test and the backend replaceable.

Architecture decisions are documented in [docs/adr](docs/adr).

## Getting started

    flutter pub get
    flutter run

## Status

Work in progress. The project foundations are in place
(architecture, linting, tests and CI); the MVP is in development.