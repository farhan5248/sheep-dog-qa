# CLAUDE.md

See [README.md](README.md) for project descriptions.

## Development Commands

### Forward Engineering (Generate test code from specifications)

```bash
# In sheep-dog-features directory
scripts/forward-engineer.bat
```

### Reverse Engineering (Update specifications from test code)

```bash
# In sheep-dog-features directory
scripts/reverse-engineer.bat <tag>
```

### Tags

- `sheep-dog-grammar` — test automation specs for the core grammar project
- `sheep-dog-dev` — development-focused specs for core libraries
- `round-trip` — round-trip engineering validation between specs and code
