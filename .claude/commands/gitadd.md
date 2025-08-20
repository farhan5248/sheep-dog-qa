**Commit Strategy:**
ALWAYS follow these steps in order:

1. **Check for unpushed commits**: Run `git log --oneline origin/main..HEAD` to see if latest commit is unpushed
2. **Apply commit decision**:
   - **IF unpushed commits exist** → amend latest commit with `git commit --amend`
   - **IF no unpushed commits** → create new commit and ask user for message
  
**Git Commit Commands:**
```bash
# Amend to latest commit (preferred when continuing work on same GitHub issue)
git add .
git commit --amend --no-edit

# Amend with updated commit message (if issue details changed)
git add .
git commit --amend -m "Updated GitHub issue title"

# New commit for new GitHub issue
# User provides issue title/description for commit message
git add .
git commit -m "<GitHub issue title/description provided by user>"
```