# Deterministic Trace Rules v0.1

1. Trace is append-only JSONL.
2. Each record includes prev_hash and record_hash.
3. Verdict must be derived from acceptance tests and evidence only.
4. No wall-clock time, randomness, or network in deterministic run path.
5. Same intent + same evidence + same acceptance => same final verdict.
