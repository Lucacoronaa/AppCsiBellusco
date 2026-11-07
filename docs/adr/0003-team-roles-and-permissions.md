# 3. Team roles and permissions

Date: 2026-11-07

## Status

Accepted

## Context

The team is self-organized: there is no club staff and the coach is also
a player. We need to decide who can do what before designing the data model
and the Firestore security rules, which are expensive to change later.

## Decision

- Roles: `coach`, `manager` and `player`. A role defines what a member can
  manage, not whether they play: every member, including the coach, is a player.
- Any member can create and edit matches and trainings.
- Only coaches and managers can publish call-ups and manage members.
- The user who creates a team becomes its manager.
- Members join with a 6-character invite code and become players immediately,
  without approval.
- For the MVP, a user belongs to one team only.
- Permissions are defined once in the domain (`TeamRole`) and enforced again
  in the Firestore security rules.

## Consequences

- The model and the security rules stay simple.
- Anyone with the invite code can join, so the code must be shared carefully
  and should be regenerable in the future.
- Supporting multiple teams per user will require a team selection screen
  and a change to the data model.