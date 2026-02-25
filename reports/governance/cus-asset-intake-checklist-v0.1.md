# CUS Asset Intake Checklist v0.1

## Provenance Required
- generator_tool
- prompt
- seed
- model
- generated_at
- output_paths
- file_sha256

## Policy Checks
- IP/style infringement risk score assigned.
- Harmful/regulated content scan recorded.
- Age-rating consistency validated.

## Approval Mapping
- Medium:
  - cosmetic-only replacement with no monetization signal change.
- High:
  - rarity signaling change tied to monetized drops,
  - purchase visibility/pressure effect likely,
  - any offer-linked visual psychology adjustment.

## Release Gate
- All assets must have provenance JSON record.
- Hash mismatch between file and evidence blocks release.
- High-tier assets require explicit human gate approval record.

## Rollback
- Revert to last approved asset bundle hash.
- Mark offending bundle as blocked in governance progress report.
- Re-run hash+policy checks before re-release.
