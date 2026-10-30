# 2. Strict linting with very_good_analysis

Date: 2026-10-30

## Status

Accepted

## Context

We want consistent and clean code from the first commit, enforced by tools
instead of manual review. The default `flutter_lints` rules are minimal.

## Decision

We use `very_good_analysis` as the base rule set, with two exceptions:

- `public_member_api_docs` is disabled: this is an app, not a library,
  so documenting every public member adds noise without real value.
- `unnecessary_type_name_in_constructor` is disabled: it requires the
  constructor syntax introduced in Dart 3.13 (`new()` instead of the class
  name). Most documentation and examples still use the classic syntax,
  so we keep it for now and will revisit this decision later.

Formatting is applied on save in VS Code and checked in CI
with `dart format --set-exit-if-changed`.

## Consequences

- Style issues are caught automatically, locally and in CI.
- The code stays consistent with the official Flutter documentation.
- Some rules can feel strict at first and require small refactors.