# Delete False Downtime Issues - Confirmation

## Confirmation: Yes, Delete the Closed Issues

**Answer: Yes, I'm confident that deleting the closed GitHub Issues will fix the problem.**

Upptime's Summary CI workflow calculates `dailyMinutesDown` by:
1. Reading ALL GitHub Issues (both open and closed) with the `incident` label
2. Calculating downtime from issue creation time to closure time
3. Aggregating minutes down per day

Since the false downtime issues are already closed, they're still being counted in the calculations. **Deleting them will remove them from the calculation.**

## Issues to Delete

Based on the [closed issues page](https://github.com/Tunnelsats/upptime/issues?q=is%3Aissue%20state%3Aclosed), these issues from December 23rd are false positives:

- **#92**: Tunnel⚡️Sats Frontend is down (closed Dec 23)
- **#93**: 🇺🇸 us1.tunnelsats.com is down (closed Dec 23)
- **#94**: 🇺🇸 us2.tunnelsats.com is down (closed Dec 23)
- **#95**: 🇺🇸 us3.tunnelsats.com is down (closed Dec 23)
- **#96**: 🇸🇬 sg1.tunnelsats.com is down (closed Dec 23)
- **#97**: 🇧🇷 br1.tunnelsats.com is down (closed Dec 23)
- **#98**: 🇩🇪 de1.tunnelsats.com is down (closed Dec 23)
- **#99**: 🇩🇪 de2.tunnelsats.com is down (closed Dec 23)
- **#100**: 🇦🇺 au1.tunnelsats.com is down (closed Dec 23)
- **#101**: Tunnel⚡️Sats Frontend is down (closed Dec 23)

**Note**: Issue #102 (us3) was a REAL downtime (502 error), so **DO NOT DELETE** that one.

## How to Delete Issues

### Option 1: Manual Deletion (Recommended)

1. Go to each issue (e.g., https://github.com/Tunnelsats/upptime/issues/92)
2. Scroll to the bottom
3. Click "Delete issue" (you may need to click "..." menu first)
4. Confirm deletion

### Option 2: GitHub CLI (Faster)

If you have GitHub CLI installed:

```bash
# Delete issues #92-101 (false positives from Dec 23)
gh issue delete 92 93 94 95 96 97 98 99 100 101 --repo Tunnelsats/upptime

# Verify deletion
gh issue list --state "all" --limit 20 --repo Tunnelsats/upptime
```

### Option 3: GitHub API Script

```bash
#!/bin/bash
# Delete false downtime issues

REPO="Tunnelsats/upptime"
TOKEN="your_github_token_here"

# Issues to delete (false positives from Dec 23)
ISSUES=(92 93 94 95 96 97 98 99 100 101)

for issue in "${ISSUES[@]}"; do
  echo "Deleting issue #$issue..."
  curl -X DELETE \
    -H "Authorization: token $TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$REPO/issues/$issue"
  sleep 1  # Rate limit protection
done

echo "Done! Issues deleted."
```

## After Deletion

1. **Manually trigger Summary CI workflow**:
   - Go to Actions → Summary CI → Run workflow
   - This will recalculate `summary.json` without the deleted issues

2. **Verify the fix**:
   - Check `history/summary.json` - should no longer have 2025-12-23 entries
   - Check badges - should show correct percentages

3. **Check for December 21st issues**:
   - You may also need to delete issues from 2025-12-21
   - Search for issues created on that date with "403 in 0 ms" in the description

## Alternative: Check for December 21st Issues

You should also check for issues from December 21st:

```bash
# Using GitHub CLI
gh issue list --state "all" --limit 100 --repo Tunnelsats/upptime | grep "2025-12-21"

# Or via web: https://github.com/Tunnelsats/upptime/issues?q=created%3A2025-12-21
```

## Important Notes

- **Issue #102 (us3)**: DO NOT DELETE - this was a real downtime
- **Backup**: Consider taking screenshots or exporting issue data before deletion (though they're false positives)
- **Permanent**: Issue deletion is permanent and cannot be undone
- **Rate Limits**: If using API/CLI, be mindful of GitHub rate limits (5000 requests/hour)

## Verification

After deletion and running Summary CI, verify:

```bash
# Check summary.json
cat history/summary.json | grep -A 5 "2025-12-23"
# Should show no entries for 2025-12-23 (except legitimate ones)

# Check summary.json for 2025-12-21
cat history/summary.json | grep -A 5 "2025-12-21"
# Should show no entries for 2025-12-21
```

## Summary

**Yes, delete the closed issues #92-101** (and any from Dec 21st). This is the correct fix because:
1. Upptime calculates downtime from GitHub Issues
2. Closed issues are still counted
3. Deleting them removes them from calculations
4. Summary CI will then recalculate correctly


