# 15. App Settings Apply Guide

## Objective
Apply app runtime changes safely by `appId`.

## Apply sequence
1. update `app_settings/{appId}` in staging
2. run smoke commands
3. verify access and billing logs
4. promote to production

## Mandatory checks
- tier configs valid
- preset/model values valid
- timeout bounds valid
- fallback path exists

## Rollback
Revert `app_settings/{appId}` to last known-good snapshot.
