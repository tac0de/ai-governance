# 12. Authorization Decision Matrix

## Objective
Standardize access decisions across DM/group chatbot workflows.

## Access policy
- Default deny
- Explicit allow via user or room document
- Expiry required for temporary access

## Decision matrix
- user allowed doc exists and active -> allow
- room allowed doc exists and active -> allow (group)
- missing/expired/inactive doc -> deny
- admin command path -> only allow listed admins

## Operational rules
- access check before AI call
- do not bypass policy for convenience
- keep audit fields on every access change
