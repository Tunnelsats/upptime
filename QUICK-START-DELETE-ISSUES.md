# Quick Start: Delete False Downtime Issues

## Yes, there are false positives from December 21st too!

From the git log, I can see multiple "403 in 0 ms" errors on Dec 21st - these are the Globalping false positives.

## Two Options

### Option 1: Automated Script (Easiest)

I've created a script that does everything for you:

```bash
cd /home/admin/tools/upptime
bash delete-false-issues.sh
```

The script will:
1. Install GitHub CLI if needed
2. Guide you through authentication
3. Find issues from both Dec 21st and Dec 23rd
4. Show you what will be deleted
5. Delete them after confirmation

### Option 2: Manual Steps

#### 1. Install GitHub CLI

```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y curl

# Add GitHub CLI repository
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Install
sudo apt-get update
sudo apt-get install -y gh
```

#### 2. Authenticate

**GitHub CLI uses OAuth, NOT SSH keys.** You have two options:

**Option A: Interactive OAuth (Recommended)**
```bash
gh auth login
# Follow prompts:
# - Choose "GitHub.com"
# - Choose "HTTPS"
# - Choose "Login with a web browser"
# - Copy code and paste in browser
```

**Option B: Personal Access Token**
```bash
# Create token at: https://github.com/settings/tokens
# Scopes needed: repo, delete_repo
# Then:
echo "your_token_here" | gh auth login --with-token
```

Verify:
```bash
gh auth status
```

#### 3. Find Issues from Both Dates

```bash
# December 21st issues
gh issue list --state "all" --limit 200 --repo Tunnelsats/upptime \
  --json number,title,createdAt,body \
  | jq '.[] | select(.createdAt | startswith("2025-12-21"))'

# December 23rd issues (we know these: #92-101)
gh issue list --state "all" --limit 200 --repo Tunnelsats/upptime \
  --json number,title,createdAt \
  | jq '.[] | select(.createdAt | startswith("2025-12-23"))'
```

#### 4. Delete Issues

**December 23rd (confirmed false positives):**
```bash
for i in {92..101}; do
  echo "Deleting issue #$i..."
  gh issue delete $i --repo Tunnelsats/upptime
  sleep 1
done
```

**December 21st (after identifying issue numbers):**
```bash
# First, get the issue numbers
DEC21_ISSUES=$(gh issue list --state "all" --limit 200 --repo Tunnelsats/upptime \
  --json number,createdAt \
  | jq -r '.[] | select(.createdAt | startswith("2025-12-21")) | .number')

# Then delete them
for issue in $DEC21_ISSUES; do
  echo "Deleting issue #$issue..."
  gh issue delete $issue --repo Tunnelsats/upptime
  sleep 1
done
```

## After Deletion

1. **Trigger Summary CI**:
   - Go to: https://github.com/Tunnelsats/upptime/actions/workflows/summary.yml
   - Click "Run workflow" → "Run workflow"

2. **Verify**:
   ```bash
   git pull
   cat history/summary.json | grep -A 5 "2025-12-21"
   cat history/summary.json | grep -A 5 "2025-12-23"
   # Should show no false downtime entries
   ```

## Important Notes

- **DO NOT DELETE Issue #102**: Real downtime (us3 502 error)
- **Authentication**: `gh` uses OAuth, not SSH keys (though you can use tokens)
- **Permanent**: Deletion cannot be undone
- **Rate Limits**: 5000 requests/hour (plenty for this task)

## Troubleshooting

**If `gh auth login` fails:**
```bash
gh auth login --hostname github.com
```

**If you get permission errors:**
- Make sure your token/user has `repo` and `delete_repo` scopes
- Check: `gh auth status`

**If jq is missing:**
```bash
sudo apt-get install -y jq
```

## Summary

- **December 21st**: Multiple issues with "403 in 0 ms" (false positives)
- **December 23rd**: Issues #92-101 (confirmed false positives)
- **Use the script**: `bash delete-false-issues.sh` (easiest)
- **Or manual**: Follow steps above


