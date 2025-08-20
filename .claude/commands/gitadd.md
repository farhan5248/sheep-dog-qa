**Commit Strategy:**
ALWAYS follow these steps in order:

1. **Check for unpushed commits**: Run `git log --oneline origin/main..HEAD` to see if latest commit is unpushed
2. **Apply commit decision**:
   - **IF unpushed commits exist** → amend latest commit
   - **IF no unpushed commits and no message provided** → create new commit using last pushed commit title
   - **IF no unpushed commits and message provided** → create new commit using provided message
  
**Usage:**
- `/gitadd` - Uses last pushed commit title for new commit
- `/gitadd "commit message"` - Uses provided message for new commit

**Git Commit Commands:**
```bash
# Amend to latest commit (preferred when continuing work on same GitHub issue)
git add .
git commit --amend --no-edit

# New commit using last pushed commit title (when no message provided)
git add .
git commit -m "$(git log origin/main -1 --pretty=format:'%s')"

# New commit using provided message
git add .
git commit -m "<provided message>"
```