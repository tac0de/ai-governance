# Top4 Account Security Runbook (Google/GitHub/Apple/ChatGPT)

## Objective
Apply a practical highest-security baseline for a solo or small-team developer environment.

## Scope
- Google account
- GitHub account
- Apple ID
- ChatGPT/OpenAI account

## Security baseline
1. Enable phishing-resistant MFA (`passkey` or `security key`) wherever supported.
2. Remove SMS-based MFA fallback where possible.
3. Store recovery codes offline in a protected location.
4. Review active sessions/devices and revoke unknown entries.

## What the operator must do directly
These actions require account login, verification challenge, or trusted-device confirmation:
- Register passkey/security key.
- Disable weak MFA methods (SMS fallback if removable).
- Download and store recovery codes.
- Confirm trusted devices/sessions.

## Optional local tracking
- Keep optional status file: `.ops/top4_security_status.json`
- Track next pending manual action in your own checklist format.

## Provider checkpoints
- Google: `passkey_or_security_key`, `sms_2fa_disabled`, `backup_codes_stored_offline`
- GitHub: `passkey_or_security_key`, `2fa_enabled`, `recovery_codes_stored_offline`
- Apple: `two_factor_enabled`, `trusted_devices_reviewed`, `recovery_contact_reviewed`
- ChatGPT/OpenAI: `mfa_enabled`, `passkey_or_totp_configured`, `active_sessions_reviewed`

## Validation
All provider controls should show complete (`3/3` per provider).
