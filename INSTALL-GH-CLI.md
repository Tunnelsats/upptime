# Install GitHub CLI and Delete False Downtime Issues

## Install GitHub CLI

### For Debian/Ubuntu (your system appears to be Debian-based):

```bash
# Install curl if not already installed
sudo apt-get update
sudo apt-get install -y curl

# Add GitHub CLI repository
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Install GitHub CLI
sudo apt-get update
sudo apt-get install -y gh
```

### Alternative: Direct download (if apt method doesn't work)

```bash
# Download latest release
curl -L https://github.com/cli/cli/releases/latest/download/gh_$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep tag_name | cut -d '"' -f 4 | cut -d 'v' -f 2)_linux_amd64.deb -o /tmp/gh.deb

# Install
sudo dpkg -i /tmp/gh.deb
sudo apt-get install -f  # Fix any dependencies
```

## Authenticate GitHub CLI

**Important**: `gh` CLI uses OAuth authentication, NOT SSH keys. However, you can use a Personal Access Token (PAT) or deploy token.

### Option 1: OAuth (Interactive - Recommended)

```bash
# This will open a browser for authentication
gh auth login

# Follow the prompts:
# 1. Choose "GitHub.com"
# 2. Choose "HTTPS" (or SSH if you prefer, but HTTPS is easier)
# 3. Choose "Login with a web browser"
# 4. Copy the code shown and paste it in the browser
# 5. Authorize the application
```

### Option 2: Personal Access Token (Non-interactive)

If you prefer using a token (useful for scripts/automation):

```bash
# Create a token at: https://github.com/settings/tokens
# Scopes needed: repo, delete_repo (for deleting issues)

# Authenticate with token
gh auth login --with-token < your_token.txt

# Or set it directly (less secure)
echo "your_token_here" | gh auth login --with-token
```

### Option 3: Use Existing GitHub Token from Environment

If you already have a `GITHUB_TOKEN` environment variable:

```bash
export GITHUB_TOKEN="your_token_here"
gh auth status  # Verify it works
```

### Verify Authentication

```bash
gh auth status
# Should show: ✓ Logged in to github.com as YOUR_USERNAME
```

## Find Issues from Both December 21st and 23rd

### List all issues to identify false positives:

```bash
# List all closed issues from Dec 21-23
gh issue list --state "all" --limit 200 --repo Tunnelsats/upptime \
  | grep -E "2025-12-2[13]|Dec 2[13]"

# Or get detailed info
gh issue list --state "all" --limit 200 --repo Tunnelsats/upptime \
  --json number,title,createdAt,closedAt,labels \
  | jq '.[] | select(.createdAt | startswith("2025-12-21") or startswith("2025-12-23"))'
```

### Check specific issues for "403" errors (false positives):

```bash
# View issue details to confirm they're false positives
gh issue view 92 --repo Tunnelsats/upptime
gh issue view 93 --repo Tunnelsats/upptime
# ... etc
```

## Delete False Positive Issues

### Step 1: Identify all false positive issues

Based on the investigation, these are likely false positives from **December 23rd**:
- Issues #92-101 (all closed on Dec 23)

For **December 21st**, we need to find them first:

```bash
# Find issues created on Dec 21
gh issue list --state "all" --limit 200 --repo Tunnelsats/upptime \
  --json number,title,createdAt,body \
  | jq -r '.[] | select(.createdAt | startswith("2025-12-21")) | "\(.number): \(.title) - \(.createdAt)"'
```

### Step 2: Delete December 23rd issues (confirmed false positives)

```bash
# Delete issues #92-101 (Dec 23 false positives)
gh issue delete 92 --repo Tunnelsats/upptime
gh issue delete 93 --repo Tunnelsats/upptime
gh issue delete 94 --repo Tunnelsats/upptime
gh issue delete 95 --repo Tunnelsats/upptime
gh issue delete 96 --repo Tunnelsats/upptime
gh issue delete 97 --repo Tunnelsats/upptime
gh issue delete 98 --repo Tunnelsats/upptime
gh issue delete 99 --repo Tunnelsats/upptime
gh issue delete 100 --repo Tunnelsats/upptime
gh issue delete 101 --repo Tunnelsats/upptime
```

### Step 3: Delete December 21st issues (after identifying them)

```bash
# First, list them to confirm
gh issue list --state "all" --limit 200 --repo Tunnelsats/upptime \
  --json number,title,createdAt,body \
  | jq '.[] | select(.createdAt | startswith("2025-12-21"))'

# Then delete them (replace X, Y, Z with actual issue numbers)
# gh issue delete X --repo Tunnelsats/upptime
# gh issue delete Y --repo Tunnelsats/upptime
# gh issue delete Z --repo Tunnelsats/upptime
```

### One-liner to delete all Dec 23 issues:

```bash
# Delete all issues #92-101 in one go
for i in {92..101}; do
  echo "Deleting issue #$i..."
  gh issue delete $i --repo Tunnelsats/upptime
  sleep 1  # Rate limit protection
done
```

## Verify Deletion

```bash
# Check that issues are gone
gh issue list --state "all" --limit 20 --repo Tunnelsats/upptime

# Verify specific issues are deleted (should error)
gh issue view 92 --repo Tunnelsats/upptime
# Should show: "Issue #92 not found"
```

## After Deletion

1. **Trigger Summary CI**:
   - Go to: https://github.com/Tunnelsats/upptime/actions/workflows/summary.yml
   - Click "Run workflow" → "Run workflow"
   - This will recalculate `summary.json` without the deleted issues

2. **Verify the fix**:
   ```bash
   # Check summary.json (after CI runs)
   git pull
   cat history/summary.json | grep -A 5 "2025-12-23"
   # Should show no entries for 2025-12-23 (except legitimate ones)
   ```

## Important Notes

- **DO NOT DELETE Issue #102**: This was a real downtime (us3 502 error)
- **Rate Limits**: GitHub API allows 5000 requests/hour for authenticated users
- **Permanent**: Issue deletion cannot be undone
- **Backup**: Consider exporting issue data first if you want a record

## Troubleshooting

### If `gh auth login` fails:
```bash
# Try with explicit hostname
gh auth login --hostname github.com

# Or use token method instead
gh auth login --with-token < token.txt
```

### If you get "permission denied":
- Make sure your token/user has `delete_repo` or `repo` scope
- Check: `gh auth status`

### If issues don't delete:
- Verify you have admin/write access to the repository
- Check: `gh repo view Tunnelsats/upptime --json permissions`


