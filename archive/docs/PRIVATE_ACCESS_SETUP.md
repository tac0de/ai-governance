# Private Access Setup

## Objective
Secure private repository and deployment credentials with minimal friction.

## Setup checklist
1. keep secrets out of git
2. store keys per environment
3. restrict admin IDs explicitly
4. rotate exposed keys immediately
5. verify CI/CD secret bindings

## Repository policy
- private repo by default
- minimal collaborator permissions
- branch protection for main

## Incident response
If a secret is exposed:
1. revoke key
2. issue new key
3. update runtime secret
4. verify no residual usage from old key
