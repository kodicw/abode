---
name: gh-cli
description: Comprehensive guide for the GitHub CLI (gh). Covers authentication, repos, issues, PRs, Actions, releases, secrets, scripting, and advanced workflows. Use when interacting with GitHub from the terminal, automating GitHub operations, or writing CI/CD workflows.
---

# GitHub CLI (gh) Guide

## Quick Reference

```bash
# Authentication
gh auth login                    # Interactive login (web or token)
gh auth status                   # Check auth state
gh auth logout                   # Remove credentials
gh auth token                    # Print current token
gh auth switch-host              # Switch between GitHub.com and GHE

# Repository
gh repo clone owner/repo         # Clone a repo
gh repo create name              # Create a new repo (local + remote)
gh repo view --web               # Open repo in browser
gh repo fork                     # Fork current repo
gh repo sync                     # Sync fork with upstream
gh repo list owner               # List repos for a user/org

# Issues
gh issue list                    # List open issues
gh issue create                  # Create new issue (interactive)
gh issue view 123                # View issue details
gh issue close 123               # Close an issue
gh issue reopen 123              # Reopen an issue
gh issue comment 123 -b "text"   # Add a comment
gh issue edit 123 --add-label bug

# Pull Requests
gh pr list                       # List open PRs
gh pr create                     # Create PR from current branch
gh pr view 456                   # View PR details
gh pr checkout 456               # Checkout a PR branch
gh pr merge 456                  # Merge a PR (--squash, --rebase)
gh pr checks 456                 # Check CI status
gh pr review 456 --approve       # Approve a PR
gh pr diff 456                   # Show PR diff
gh pr status                     # Show PR status for current branch

# Actions
gh run list                      # List workflow runs
gh run view 1234567890           # View run details
gh run watch 1234567890          # Watch run in real-time
gh run rerun 1234567890          # Rerun a failed run
gh run cancel 1234567890         # Cancel a run
gh workflow list                 # List workflows
gh workflow enable/disable name  # Toggle workflow

# Releases
gh release list                  # List releases
gh release create v1.0.0         # Create a release (attach files with --attach)
gh release upload v1.0.0 file    # Upload assets
gh release download v1.0.0       # Download assets
gh release delete v1.0.0         # Delete a release

# Gists
gh gist create file.txt          # Create a gist
gh gist list                     # List your gists
gh gist view ID                  # View a gist
gh gist edit ID                  # Edit a gist
gh gist delete ID                # Delete a gist

# Secrets & Variables
gh secret list                   # List repo secrets
gh secret set NAME --body value  # Set a secret
gh variable list                 # List repo variables
gh variable set NAME --body val  # Set a variable

# General
gh api <endpoint>                # Make arbitrary API calls
gh api repos/:owner/:repo/issues
gh browse [path]                 # Open repo/path in browser
gh search issues "query"         # Search issues across GitHub
gh search prs "query"
gh search repos "query"
gh alias list / set / delete     # Manage aliases
gh extension list / install      # Manage extensions
```

## Authentication

### Login methods

```bash
gh auth login                    # Web browser flow (default)
gh auth login --with-token < token.txt  # Token from stdin
GH_TOKEN=xxx gh repo list        # One-shot with env var
```

### Enterprise Server (GitHub Enterprise)

```bash
gh auth login --hostname github.example.com
gh auth status
gh auth switch-host              # switch between github.com and GHE
```

### Token Scopes

For full functionality, the token needs:
- `repo` — full repo access
- `workflow` — read/write Actions workflows
- `gist` — create gists
- `read:packages` / `write:packages` — for packages
- `admin:repo_hook` — for webhooks

## Repository Operations

```bash
# Create and push new repo
gh repo create myproject --public --source=. --remote=origin --push

# Clone with gh (uses HTTPS but with gh credential helper)
gh repo clone cli/cli

# View repo info (json output for scripting)
gh repo view --json name,owner,description,defaultBranchRef,pullRequests

# Fork current repo under your account
gh repo fork --remote --remote-name upstream

# Sync a forked repo
gh repo sync owner/repo --branch main
```

## Issues

### Create with flags

```bash
gh issue create --title "Bug: crash on startup" \
  --body "Steps to reproduce..." \
  --label bug --assignee @me --milestone v1.0
```

### List with filters

```bash
gh issue list --state closed --label bug --milestone v1.0 --assignee @me
gh issue list --search "crash in:title" --json number,title,url
```

### Bulk operations via API

```bash
# Close all stale issues
gh issue list --label stale --json number --jq '.[].number' | \
  xargs -I {} gh issue close {} --reason "not planned"
```

## Pull Requests

### Create PR

```bash
gh pr create --fill                    # Use commit message as title/body
gh pr create --title "Fix login" --body "Closes #123" --draft
gh pr create --base main --head feature-branch --web  # Open web editor
```

### Review PRs

```bash
gh pr list --search "is:open review-requested:@me"
gh pr checkout 456                     # Checkout PR branch locally
gh pr review 456 --approve --body "LGTM"
gh pr review 456 --request-changes --body "See comments"
gh pr review 456 --comment --body "Nit: formatting"
```

### Merge strategies

```bash
gh pr merge 456 --squash --delete-branch
gh pr merge 456 --rebase --auto        # Enable auto-merge
gh pr merge 456 --merge
```

### PR checks and status

```bash
gh pr checks 456 --watch               # Watch until completion
gh pr checks 456 --fail-fast           # Exit 1 on first failure
gh pr status                           # Status of PR for current branch
```

## GitHub Actions

### Monitor runs

```bash
gh run list --workflow=ci.yml --limit 10
gh run view 1234567890 --log            # Show full logs
gh run view 1234567890 --log-failed     # Show only failed steps
gh run watch 1234567890                 # Live follow
gh run rerun 1234567890 --failed        # Rerun only failed jobs
gh run rerun 1234567890 --debug         # Enable debug logging
```

### Workflow management

```bash
gh workflow list
gh workflow view ci.yml --yaml          # View workflow YAML
gh workflow run ci.yml --ref main -f input=value
gh workflow enable ci.yml
gh workflow disable ci.yml
```

### Download artifacts

```bash
gh run download 1234567890              # Download all artifacts
gh run download 1234567890 --name dist  # Download specific artifact
```

## Releases

```bash
# Create release with assets
gh release create v1.0.0 \
  --title "Version 1.0.0" \
  --notes "Release notes here" \
  --attach ./dist/app.tar.gz \
  --attach ./dist/app.dmg

# Generate release notes from PRs since last tag
gh release create v1.0.0 --generate-notes

# Update release notes
gh release edit v1.0.0 --notes "Updated notes"

# Download latest release asset
gh release download --repo owner/repo --pattern "*.tar.gz"
```

## Scripting with `--json` and `--jq`

Almost every `list` and `view` command supports `--json` for structured output and `--jq` for filtering.

### JSON fields

```bash
gh pr list --json number,title,author,createdAt,url
gh issue view 123 --json number,title,body,labels
gh repo view --json nameWithOwner,stargazerCount,forkCount
```

### jq filtering

```bash
# Get just PR numbers
gh pr list --json number --jq '.[].number'

# Filter PRs by author
gh pr list --json number,title,author --jq '.[] | select(.author.login == "octocat")'

# Format as markdown table
gh pr list --json number,title,author --jq |
  jq -r '.[] | "| #\(.number) | \(.title) | @\(.author.login) |"'

# Count open issues
gh issue list --json number --jq 'length'
```

### API scripting

```bash
# GET request
gh api repos/:owner/:repo/issues --jq '.[].title'

# POST request
gh api repos/:owner/:repo/issues \
  --method POST \
  --field title="New Issue" \
  --field body="Description"

# GraphQL
gh api graphql -f query='
  query {
    viewer { login name }
  }'
```

## Aliases

Create shortcuts for common commands:

```bash
gh alias set co "pr checkout"
gh alias set view "pr view --web"
gh alias set pv "pr view --json number,title,state --jq '.[] | "\(.state): #\(.number) \(.title)"'"
gh alias set issues "issue list --assignee @me --state open"

gh alias list
gh alias delete co
```

## Extensions

```bash
gh extension list                    # List installed extensions
gh extension install owner/gh-repo   # Install from GitHub repo
gh extension install local/path      # Install from local path
gh extension upgrade --all           # Upgrade all extensions
gh extension remove owner/gh-repo    # Remove an extension
```

Popular extensions:
- `dlvhdr/gh-dash` — Dashboard for PRs/issues
- `yusukebe/gh-markdown-preview` — Preview markdown locally
- `gennaro-tedesco/gh-s` — Interactive PR/issue selector

## Searching GitHub

```bash
# Search issues across all repos
gh search issues "memory leak" --repo=owner/repo --state=open

# Search PRs
gh search prs "fix auth" --author=octocat --state=merged

# Search repos
gh search repos "nvim config" --sort stars --limit 10

# Search code
gh search code "function setup" --language=typescript
```

## Codespaces

```bash
gh codespace list
gh codespace create --repo owner/repo --branch main
gh codespace code -c CODESPACE_NAME    # Open in VS Code
gh codespace ssh -c CODESPACE_NAME     # SSH into codespace
gh codespace delete -c CODESPACE_NAME
```

## Advanced Patterns

### Bulk PR creation with xargs

```bash
cat branches.txt | xargs -I {} sh -c '
  git checkout -b "feat/{}"
  git push -u origin "feat/{}"
  gh pr create --title "Add {}" --body "Implementation for {}"
'
```

### CI-triggered PR merge

```bash
# Wait for checks, then auto-merge
gh pr checks 456 --watch && gh pr merge 456 --squash --delete-branch
```

### Create issue from template

```bash
gh issue create --template bug_report.yml --label bug
```

### Environment variables

| Variable | Purpose |
|----------|---------|
| `GH_TOKEN` | Auth token (overrides stored creds) |
| `GH_HOST` | Default GitHub hostname |
| `GH_EDITOR` | Editor for interactive prompts |
| `GH_PAGER` | Pager for output |
| `GH_NO_UPDATE_NOTIFIER` | Disable update checks |
| `DEBUG=api` | Verbose API logging |

## Pitfalls

| Issue | Solution |
|-------|----------|
| `gh` asks for auth repeatedly in scripts | Use `GH_TOKEN` env var or run `gh auth login` first |
| Cannot create PR from fork | Use `--head fork-owner:branch` |
| Large `--json` output truncated | Pipe to file or use `--jq` to filter |
| `gh api` URLs need escaping | Use `:owner/:repo` shorthand or quote carefully |
| Confused about current repo | `gh repo view` shows which repo gh is targeting |
| Rate limited | Use authenticated requests; check `gh api rate_limit` |
| Actions logs too long | Use `--log-failed` or grep the output |

## External References

- `gh --help` and `gh <command> --help`
- `gh help references` — longer help topics
- https://cli.github.com/manual — official manual
- https://github.com/cli/cli — source code
- `man gh` — man page (if installed)
