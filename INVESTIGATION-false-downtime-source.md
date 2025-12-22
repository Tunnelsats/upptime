# Investigation: False Downtime Source and Solution

## Root Cause Analysis

### How Upptime Calculates Downtime

Upptime calculates `dailyMinutesDown` from **GitHub Issues**, not from `summary.json` or history YAML files:

1. **When a service goes down**: Upptime creates a GitHub Issue with label `incident`
2. **When a service comes back up**: Upptime closes the issue
3. **Summary CI calculates downtime**: It reads all open/closed issues and calculates total minutes down per day based on issue creation/closure times
4. **`summary.json` is regenerated**: The Summary CI workflow recalculates everything from the GitHub Issues

This is why manually editing `summary.json` doesn't work - it gets overwritten on the next Summary CI run.

### The Problem

1. **False 403 errors on 2025-12-21 and 2025-12-23**: Globalping returned HTTP 403 with 0ms response time (rate limiting)
2. **Upptime created GitHub Issues**: For each service that appeared "down" due to the 403 errors
3. **Issues were eventually closed**: When services appeared to come back "up"
4. **Summary CI recalculated**: Including the false downtime from those issues

### Current Status

- **us3-tunnelsats-com**: Currently showing `status: down` with `code: 502` (real issue, not false positive)
- **False downtimes**: Still present in `summary.json` because the GitHub Issues exist

## Solution

### Step 1: Delete False Downtime Issues

**IMPORTANT**: Upptime calculates downtime from **both open AND closed** GitHub Issues. Simply closing them isn't enough - you need to **DELETE** them.

You need to find and delete GitHub Issues created on 2025-12-21 and 2025-12-23 for the false downtime:

1. Go to your GitHub repository: `https://github.com/Tunnelsats/upptime/issues`
2. Filter by:
   - State: `closed`
   - Created: `2025-12-21` or `2025-12-23`
   - Or search for: `"403 in 0 ms"` or `"Globalping"`

3. **Delete each false downtime issue** (not just close):
   - Go to the issue
   - Scroll to bottom
   - Click "Delete issue" (may be under "..." menu)
   - Confirm deletion

**Issues to delete from Dec 23rd**: #92, #93, #94, #95, #96, #97, #98, #99, #100, #101
**DO NOT DELETE**: Issue #102 (us3) - this was a real downtime

See `DELETE-FALSE-DOWNTIME-ISSUES.md` for detailed instructions and scripts.

### Step 2: Verify us3 Status

us3 is currently returning HTTP 502. You need to verify:
- Is this a real outage?
- Or is this another false positive?

Check:
```bash
curl -I https://us3.tunnelsats.com
```

If it's a false positive, close the GitHub Issue for us3 as well.

### Step 3: Check GLOBALPING_TOKEN Secret

According to PR #267 and the documentation, Upptime should use `GLOBALPING_TOKEN` (not `GLOBALPING_API_KEY`) if it exists:

1. Go to repository Settings → Secrets and variables → Actions
2. Check if `GLOBALPING_TOKEN` exists
3. If it doesn't exist and you want to use Globalping with authentication:
   - Get a token from Globalping dashboard
   - Add it as `GLOBALPING_TOKEN` secret
   - This increases limit from 250 to 500 tests/hour

**Note**: Since we removed Globalping from `.upptimerc.yml`, this token won't be used anyway. But if PR #267 adds better Globalping support, you might want to re-enable it with the token.

### Step 4: After Closing Issues

Once you close the false downtime issues:

1. **Manually trigger Summary CI**: It will recalculate `summary.json` without the false downtime
2. **Verify**: Check that `dailyMinutesDown` no longer includes 2025-12-21 and 2025-12-23
3. **Update badges**: The badges should automatically update to reflect correct percentages

## Files That Need Manual Updates (After Closing Issues)

After closing the GitHub Issues and running Summary CI, you may still need to update:

1. **`api/*/uptime-day.json`**: 24-hour badges (should auto-update, but verify)
2. **`api/*/uptime-week.json`**: Week badges (should auto-update)
3. **`api/*/uptime-month.json`**: Month badges (should auto-update)
4. **`api/*/uptime-year.json`**: Year badges (should auto-update)

## About PR #267

PR #267 likely addresses:
- Better Globalping token support (`GLOBALPING_TOKEN`)
- Improved error handling for Globalping rate limits
- Possibly fallback mechanisms

You should:
1. Check if the PR is merged
2. If merged, update your Upptime template to get the latest version
3. Consider re-enabling Globalping with `GLOBALPING_TOKEN` if the improvements address your issues

## Quick Fix Script

To find issues programmatically (if you have GitHub CLI):

```bash
gh issue list --label "incident" --state "all" --limit 100 | grep "2025-12-2[13]"
```

Or via GitHub API:
```bash
curl -H "Authorization: token YOUR_TOKEN" \
  "https://api.github.com/repos/Tunnelsats/upptime/issues?labels=incident&state=all&per_page=100" \
  | jq '.[] | select(.created_at | startswith("2025-12-21") or startswith("2025-12-23"))'
```

## Summary

**The real fix**: Close the GitHub Issues for false downtime, then run Summary CI.

**Why summary.json keeps getting overwritten**: It's calculated from GitHub Issues, not stored statically.

**us3 502 error**: Verify if real or false positive, then close the issue if false.

**GLOBALPING_TOKEN**: Check if it exists, but won't be used since we removed Globalping from config.

