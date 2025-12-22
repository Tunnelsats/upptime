#!/bin/bash
# Script to install GitHub CLI and delete false downtime issues
# Run this script: bash delete-false-issues.sh

set -e

echo "=========================================="
echo "GitHub CLI Installation and Issue Cleanup"
echo "=========================================="
echo ""

# Step 1: Install GitHub CLI
echo "Step 1: Installing GitHub CLI..."
if command -v gh &> /dev/null; then
    echo "✓ GitHub CLI is already installed"
    gh --version
else
    echo "Installing GitHub CLI..."
    
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
    
    echo "✓ GitHub CLI installed successfully"
    gh --version
fi

echo ""
echo "Step 2: Authenticating with GitHub..."
echo ""

# Check if already authenticated
if gh auth status &> /dev/null; then
    echo "✓ Already authenticated"
    gh auth status
else
    echo "You need to authenticate. Choose one:"
    echo ""
    echo "Option 1: Interactive OAuth (recommended)"
    echo "  This will open a browser for authentication"
    echo "  Run: gh auth login"
    echo ""
    echo "Option 2: Use Personal Access Token"
    echo "  Create token at: https://github.com/settings/tokens"
    echo "  Scopes needed: repo, delete_repo"
    echo "  Run: echo 'your_token' | gh auth login --with-token"
    echo ""
    read -p "Press Enter after you've authenticated, or Ctrl+C to exit and authenticate manually..."
    
    # Verify authentication
    if ! gh auth status &> /dev/null; then
        echo "❌ Authentication failed. Please run 'gh auth login' manually."
        exit 1
    fi
fi

echo ""
echo "Step 3: Finding false downtime issues..."
echo ""

REPO="Tunnelsats/upptime"

# Find issues from Dec 21st
echo "Issues from December 21st (false positives with 403 errors):"
gh issue list --state "all" --limit 200 --repo "$REPO" \
  --json number,title,createdAt,body \
  | jq -r '.[] | select(.createdAt | startswith("2025-12-21")) | "  #\(.number): \(.title) - Created: \(.createdAt)"' || echo "  (No issues found or jq not installed)"

echo ""
echo "Issues from December 23rd (confirmed false positives):"
gh issue list --state "all" --limit 200 --repo "$REPO" \
  --json number,title,createdAt \
  | jq -r '.[] | select(.createdAt | startswith("2025-12-23")) | "  #\(.number): \(.title) - Created: \(.createdAt)"' || echo "  (No issues found or jq not installed)"

echo ""
echo "Step 4: Confirming issues to delete..."
echo ""

# December 23rd issues (confirmed false positives)
DEC23_ISSUES=(83 84 85 86 87 88 89 90 91)

echo "December 23rd issues to delete: ${DEC23_ISSUES[*]}"
echo ""
echo "⚠️  IMPORTANT: Issue #102 (us3) should NOT be deleted - it was a real downtime!"
echo ""

# Get December 21st issues
echo "Fetching December 21st issues..."
DEC21_ISSUES=$(gh issue list --state "all" --limit 200 --repo "$REPO" \
  --json number,title,createdAt,body \
  | jq -r '.[] | select(.createdAt | startswith("2025-12-21")) | .number' | tr '\n' ' ')

if [ -z "$DEC21_ISSUES" ]; then
    echo "No December 21st issues found (or jq not installed)"
    DEC21_ISSUES=()
else
    echo "December 21st issues found: $DEC21_ISSUES"
    read -p "Do you want to delete these December 21st issues? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        DEC21_ISSUES=()
        echo "Skipping December 21st issues"
    fi
fi

echo ""
read -p "Ready to delete the issues listed above? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled. No issues deleted."
    exit 0
fi

echo ""
echo "Step 5: Deleting issues..."
echo ""

# Delete December 23rd issues
for issue in "${DEC23_ISSUES[@]}"; do
    echo "Deleting issue #$issue..."
    if gh issue delete "$issue" --repo "$REPO" 2>/dev/null; then
        echo "  ✓ Deleted issue #$issue"
    else
        echo "  ✗ Failed to delete issue #$issue (may already be deleted)"
    fi
    sleep 1  # Rate limit protection
done

# Delete December 21st issues
if [ ! -z "$DEC21_ISSUES" ]; then
    for issue in $DEC21_ISSUES; do
        echo "Deleting issue #$issue..."
        if gh issue delete "$issue" --repo "$REPO" 2>/dev/null; then
            echo "  ✓ Deleted issue #$issue"
        else
            echo "  ✗ Failed to delete issue #$issue (may already be deleted)"
        fi
        sleep 1  # Rate limit protection
    done
fi

echo ""
echo "=========================================="
echo "✓ Done! Issues deleted."
echo ""
echo "Next steps:"
echo "1. Go to: https://github.com/Tunnelsats/upptime/actions/workflows/summary.yml"
echo "2. Click 'Run workflow' → 'Run workflow'"
echo "3. This will recalculate summary.json without the false downtime"
echo "=========================================="


