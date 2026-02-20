# Security Policy

## Reporting Security Vulnerabilities

### Private Reporting
**Do NOT create public issues for security vulnerabilities.**

Instead, please report vulnerabilities through one of these private channels:
- Contact the repository owner directly
- Email: (contact owner for email address)

### What to Include
When reporting, please include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact assessment
- Any suggested fixes (optional)

### What NOT to Include
- Do NOT include actual exploit code
- Do NOT create public pull requests for security fixes
- Do NOT discuss vulnerabilities in public issues

---

## Response SLA

| Stage | Timeline |
|-------|----------|
| Initial Acknowledgment | Within 72 hours |
| Initial Assessment | Within 7 days |
| Fix Timeline | Depends on severity |

---

## Secrets and Credentials

### Strictly Forbidden
- **NEVER commit** API keys, tokens, secrets, or credentials to this repository
- **NEVER commit** private keys, passwords, or sensitive configuration
- **NEVER commit** environment files containing secrets (`.env`, `*.local.json`)

### Detection
The repository includes automated guards:
- `scripts/pii_guard.sh` - PII detection
- `scripts/secret_scan.sh` - Secret scanning
- Pre-commit hooks for local validation

### If You Accidentally Exposed Secrets
1. **Immediately** rotate the exposed credentials
2. Report to repository owner
3. Do NOT attempt to "fix" by adding more secrets to the history

---

## Responsible Disclosure

- We appreciate responsible disclosure of security issues
- We will work with reporters on timelines and credits
- We request that you give us reasonable time to fix before public disclosure
- Security issues are processed separately from regular PR workflow

---

## Security Boundaries

This repository follows these security principles:
1. **Local-first**: Sensitive operations run locally, not in hosted AI services
2. **Minimal privilege**: Only necessary permissions are granted
3. **Audit trail**: All significant actions are logged
4. **Human approval**: High-risk operations require human decision

---

## Security Issues vs. Regular Issues

| Type | Channel | Process |
|------|---------|---------|
| Security vulnerability | Private (email/direct) | Separate triage |
| Bug/Feature | Public issue | Standard PR process |

**Note**: Security issues are NOT processed through standard Pull Requests to prevent premature exposure of vulnerabilities.
