# Fix Globalping Configuration and Remove False Downtime

## Summary

This PR addresses recurring false-positive HTTP 403 errors from Globalping that have been incorrectly recording downtime for all Tunnel⚡️Sats servers. The changes include:

1. **Configuration Validation**: Validated Globalping setup against official documentation
2. **Rate Limit Analysis**: Calculated ping rates to identify potential API limit issues
3. **False Downtime Removal**: Removed false downtime entries for 2025-12-21 and 2025-12-23
4. **Badge Updates**: Updated all uptime badge JSON files to reflect corrected 100% status
5. **Globalping Removal**: Removed Globalping integration and switched to default GitHub Actions runner

## Problem Analysis

### Configuration Issues

The current `.upptimerc.yml` configuration was missing the optional `location` parameter for Globalping endpoints. According to the [Upptime documentation](https://upptime.js.org/docs/configuration#globalping), while `location` defaults to "World", it's recommended to specify it explicitly for better reliability.

### Rate Limit Calculation

**Current Setup:**
- **Active sites**: 10 endpoints (9 servers + 1 frontend)
- **Check frequency**: Every 5 minutes (`*/5 * * * *`)
- **Checks per hour**: 12 runs/hour
- **Total pings per hour**: 10 sites × 12 checks = **120 pings/hour**

**Rate Limit Analysis:**
- **Unauthenticated Globalping limit**: 250 tests/hour per IP address
- **Theoretical limit**: 120 pings/hour is well under the 250/hour limit
- **Actual issue**: GitHub Actions runners share IP addresses among multiple users, causing premature rate limiting
- **Result**: False 403 errors when the shared IP hits the limit before our 120 pings are reached

### False Downtime Events

Two separate incidents of false downtime were recorded:
- **2025-12-21**: 20 minutes of false downtime for all servers (previously fixed, but re-occurred)
- **2025-12-23**: 55 minutes of false downtime for most servers, 122 minutes for de3

Both incidents were caused by Globalping returning HTTP 403 errors with 0ms response times, indicating API rate limiting rather than actual service outages.

## Solution

### 1. Removed Globalping Integration

Since Upptime does not support a fallback mechanism (Globalping error → GitHub runner), the most reliable solution is to remove Globalping entirely and use the default GitHub Actions runner. This provides:

- **No rate limiting issues**: GitHub Actions runners don't have the shared IP rate limit problem
- **More reliable monitoring**: Direct checks from GitHub's infrastructure
- **Simpler configuration**: Removes dependency on external service

**Changes made:**
- Removed `type: globalping` from all 10 site configurations in `.upptimerc.yml`
- All endpoints now use the default GitHub Actions runner

### 2. Fixed Historical Data

**`history/summary.json`:**
- Removed `"2025-12-21": 20` from all affected servers
- Removed `"2025-12-23": 55` (or `122` for de3) from all affected servers
- Preserved all legitimate downtime entries (e.g., `"2025-03-03": 10`, `"2025-10-01": 25`)

**Affected services:**
- us1-tunnelsats-com
- us2-tunnelsats-com
- us3-tunnelsats-com
- sg1-tunnelsats-com
- br1-tunnelsats-com
- de1-tunnelsats-com
- de2-tunnelsats-com
- de3-tunnelsats-com
- au1-tunnelsats-com
- tunnel-sats-frontend

### 3. Updated API Badges

**24-hour uptime badges (`api/*/uptime-day.json`):**
- Updated all 10 services from ~96% back to `"100%"`
- Maintained `color: "brightgreen"` and proper JSON schema

**Overall uptime badges (`api/*/uptime.json`):**
- Verified all badges match the corrected values from `summary.json`
- No changes needed as overall uptime percentages were already accurate (yearly calculation wasn't significantly affected by 20-55 minute false incidents)

## Alternative Solution Considered

**Option: Add Globalping Authentication Token**
- Could increase limit from 250 to 500 tests/hour
- Would require adding `GLOBALPING_TOKEN` secret to repository
- Still vulnerable to Globalping service issues
- **Decision**: Rejected in favor of removing Globalping for better reliability

## Testing

After merging this PR:
1. The Summary CI workflow will automatically rebuild the README and status page
2. All badges should display 100% for 24-hour uptime
3. Future monitoring will use GitHub Actions runners, eliminating rate limit issues
4. No more false 403 errors from Globalping

## Files Modified

### Configuration
- `.upptimerc.yml` - Removed `type: globalping` from all 10 site entries

### Historical Data
- `history/summary.json` - Removed false downtime entries for 2025-12-21 and 2025-12-23

### API Badges (24-hour uptime)
- `api/us1-tunnelsats-com/uptime-day.json`
- `api/us2-tunnelsats-com/uptime-day.json`
- `api/us3-tunnelsats-com/uptime-day.json`
- `api/sg1-tunnelsats-com/uptime-day.json`
- `api/br1-tunnelsats-com/uptime-day.json`
- `api/de1-tunnelsats-com/uptime-day.json`
- `api/de2-tunnelsats-com/uptime-day.json`
- `api/de3-tunnelsats-com/uptime-day.json`
- `api/au1-tunnelsats-com/uptime-day.json`
- `api/tunnel-sats-frontend/uptime-day.json`

## References

- [Upptime Globalping Configuration Documentation](https://upptime.js.org/docs/configuration#globalping)
- [Globalping Blog: Global Uptime Monitoring with Upptime](https://blog.globalping.io/global-uptime-monitoring-upptime-globalping/)

## Rationale

This change ensures:
1. **Data Accuracy**: Historical data reflects actual service availability, not monitoring artifacts
2. **Reliability**: GitHub Actions runners provide more stable monitoring without external API dependencies
3. **Trust**: Public SLA percentages accurately represent service reliability
4. **Simplicity**: Removes complexity of managing external API tokens and rate limits

