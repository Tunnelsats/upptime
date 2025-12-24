## Summary

This PR corrects a false 20-minute downtime incident recorded on **2025‑12‑21** for all Tunnel⚡️Sats services, which was caused by a monitoring provider (Globalping) returning spurious HTTP 403 responses. It updates `history/summary.json` to set `"2025-12-21"` daily downtime to `0` for all affected services and adjusts the precomputed uptime badges under `api/*/uptime-day.json` and `api/*/uptime.json` so that the 24h and overall uptime values report **100%** where appropriate. No other dates or downtime values are changed.

## Details of Changes

- **`history/summary.json`**
  - For every service entry, within `dailyMinutesDown`, the value for `"2025-12-21"` is set from `20` → `0`.
  - All other dates (e.g. `"2025-03-03"`, `"2025-05-05"`, etc.) remain untouched.

- **24h uptime badges**
  - In each `api/*/uptime-day.json`, the JSON schema is preserved and:
    - `label` stays `"uptime 24h"`.
    - `color` stays `"brightgreen"`.
    - `message` is updated from `"98.6%"` / `"98.61%"` to `"100%"` to reflect that there was no real downtime on 2025‑12‑21.

- **Overall uptime badges**
  - In each `api/*/uptime.json`, the JSON schema is preserved and:
    - `label` stays `"uptime"`.
    - `color` stays `"brightgreen"`.
    - `message` is set to `"100%"` wherever the only deviation from 100% came from the false 20-minute incident.
  - Entries that were already at `"100%"` remain unchanged in value, but are normalized through this pass.

- **History YAMLs**
  - `history/*.yml` files were inspected for explicit 2025‑12‑21 “down” events.
  - These files only contain summary metadata fields (no per-date events), so no YAML edits are required to prevent re-introduction of this downtime.

## Rationale

- **Data correctness**: The 20-minute “outage” on 2025‑12‑21 was a monitoring artifact, not a real production incident. Keeping this data would misrepresent the actual reliability of the platform and mislead consumers of the public status page and README badges.
- **Trust in SLAs and status page**: Public uptime/SLA metrics are used by users and integrators to assess risk. Showing an artificial dip due to an upstream monitoring provider issue undermines trust in these numbers; correcting the data keeps the SLAs aligned with real-world service behavior.
- **Minimal, targeted fix**: The change is intentionally scoped:
  - Only the specific date `2025‑12‑21` is altered.
  - Only the entries directly tied to the false 403 signals are modified.
  - Historical, legitimate downtime on other dates is preserved intact.
- **Consistency between history and badges**: By fixing both `history/summary.json` and the derived `api/*/uptime*.json` badges, we ensure that:
  - The raw historical data no longer encodes the false downtime.
  - The user‑facing badges (24h and overall uptime) accurately reflect the corrected history and remain synchronized with what the CI will recompute going forward.



