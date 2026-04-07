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

- `asciidoc-api` — AsciiDoc to UML API library
- `cucumber-gen` — Cucumber code generation library
- `grammar` — core grammar project
- `svc-maven-plugin` — service Maven plugin
- `asciidoc-api-svc` — AsciiDoc API microservice
- `cucumber-gen-svc` — Cucumber code generation microservice
- `mcp-svc` — MCP server implementation
