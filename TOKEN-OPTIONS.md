# Token Options for Deleting Issues

## Quick Answer

**You don't need a deploy token.** A **fine-grained Personal Access Token (PAT)** scoped to just the `Tunnelsats/upptime` repository is the best option.

## Token Options Explained

### Option 1: Fine-Grained Personal Access Token (Recommended)

**Best for this use case** - scoped to just your repository with minimal permissions.

1. Go to: https://github.com/settings/tokens?type=beta
2. Click "Generate new token" → "Generate new token (fine-grained)"
3. Configure:
   - **Token name**: `upptime-issue-cleanup` (or similar)
   - **Expiration**: Choose appropriate (30 days, 90 days, or custom)
   - **Repository access**: Select "Only select repositories"
   - **Repositories**: Select `Tunnelsats/upptime`
   - **Repository permissions**:
     - **Issues**: `Read and write` (this includes delete)
     - **Metadata**: `Read-only` (always required)
4. Click "Generate token"
5. Copy the token immediately (you won't see it again)

**Use it:**
```bash
echo "ghp_xxxxxxxxxxxx" | gh auth login --with-token
```

**Advantages:**
- ✅ Scoped to only the `upptime` repository
- ✅ Minimal permissions (just Issues + Metadata)
- ✅ Can be revoked easily
- ✅ Shows up in repository audit log

### Option 2: Classic Personal Access Token

**Works, but broader scope** - applies to all your repositories.

1. Go to: https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Configure:
   - **Note**: `upptime-issue-cleanup`
   - **Expiration**: Choose appropriate
   - **Scopes**: Check only `repo` (this includes delete issues)
4. Click "Generate token"
5. Copy the token

**Use it:**
```bash
echo "ghp_xxxxxxxxxxxx" | gh auth login --with-token
```

**Advantages:**
- ✅ Simple to create
- ✅ Works immediately

**Disadvantages:**
- ❌ Applies to ALL your repositories (broader than needed)
- ❌ Can't be scoped to just one repository

### Option 3: Deploy Token (Not Recommended)

**Not suitable for this use case** - deploy tokens have very limited permissions.

Deploy tokens are designed for:
- Cloning repositories
- Reading repository contents
- Pushing code (with write access)

**They typically CANNOT:**
- ❌ Delete issues
- ❌ Manage issues (create/close/delete)
- ❌ Access GitHub API for issue management

**Why not use it:**
- Deploy tokens are meant for CI/CD and automation
- They don't have the `repo` scope needed for issue deletion
- GitHub CLI (`gh`) requires broader permissions than deploy tokens provide

## Required Permissions

To delete issues via GitHub CLI, you need:

- **Minimum**: `repo` scope (classic PAT) OR `Issues: Read and write` (fine-grained PAT)
- **Repository**: Must have access to `Tunnelsats/upptime`
- **User**: Must have write/admin access to the repository

## Recommendation

**Use a Fine-Grained PAT** (Option 1) because:
1. ✅ Scoped to just the `upptime` repository
2. ✅ Minimal permissions (only Issues + Metadata)
3. ✅ More secure than classic PAT
4. ✅ Can be easily revoked
5. ✅ Shows in repository audit log

## Security Best Practices

1. **Set expiration**: Don't create tokens that never expire
2. **Use fine-grained**: More control over permissions
3. **Scope to repository**: Only grant access to what's needed
4. **Revoke after use**: Delete the token after cleanup is done
5. **Don't commit tokens**: Never commit tokens to git

## Example: Creating Fine-Grained PAT

```bash
# 1. Go to: https://github.com/settings/tokens?type=beta
# 2. Create token with:
#    - Repository: Tunnelsats/upptime
#    - Permissions: Issues (Read and write), Metadata (Read-only)
# 3. Copy token
# 4. Use it:

echo "ghp_xxxxxxxxxxxx" | gh auth login --with-token

# 5. Verify:
gh auth status

# 6. Test:
gh issue list --repo Tunnelsats/upptime --limit 1

# 7. After cleanup, revoke token at:
#    https://github.com/settings/tokens?type=beta
```

## Summary

- **Don't use deploy token**: Doesn't have issue deletion permissions
- **Use fine-grained PAT**: Scoped to just the repository, minimal permissions
- **Classic PAT works**: But applies to all repositories (broader than needed)
- **Revoke after use**: Delete the token once cleanup is complete


