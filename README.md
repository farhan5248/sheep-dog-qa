# Sheep Dog Specs

The specification hub for the sheep-dog ecosystem, containing three types of specs:

- **Architectural specs** (`site/`) — high-level architecture decisions and implementation guides
- **Behavioral specs** (`sheep-dog-features/src/test/resources/asciidoc/`) — AsciiDoc documents that define system behavior, the single source of truth from which test automation code is generated
- **Operational specs** (`sheep-dog-features/kubernetes/`) — Kubernetes deployment manifests for dev/qa environments

## Projects

| Directory | Description |
|-----------|-------------|
| site | Architectural and implementation documentation |
| sheep-dog-features | BDD specifications, forward/reverse engineering scripts, Kubernetes deployment configs |

## Documentation map

Documentation is split across several locations, each with a distinct purpose. Consult the home that matches the kind of information you are looking for.

| Location | Purpose |
|----------|---------|
| `<repo>/CLAUDE.md` | Project instructions for Claude Code — conventions, workflows, ecosystem coordination |
| `<repo>/README.md` | Human-facing overview of a repository or project |
| `sheep-dog-features/src/test/resources/asciidoc/` | **Behavioral specs** — AsciiDoc files that define system behavior; generated test code flows from these |
| `site/arch/` | **Architecture specs** — cross-cutting framework behavior, patterns, and hierarchy decisions |
| `site/impl/` | **Implementation contracts** — handcrafted code choices (impl class rules, reference TestObject samples) |
| `site/impl/samples/` | **Canonical source samples** — reference `.java` files that every project's equivalent must match |
| `<repo>/.claude/skills/` | **Auto-generation rules** — skills that drive rgr-red/green/refactor and other automated workflows |
| `<project>/site/uml/` | **Project-specific patterns** — UML and spec files that constrain the generated code in one project |

Rule of thumb: if a piece of knowledge applies to every project, it belongs in `site/arch` or `site/impl`. If it applies to one project only, it belongs in that project's `site/uml`. If it drives code generation rather than describing the result, it belongs in a skill.

## Behavioral Specs

Specifications are organized by tag, each targeting a different component:
- **asciidoc-api** — AsciiDoc to UML API library
- **cucumber-gen** — Cucumber code generation library
- **grammar** — core grammar project
- **svc-maven-plugin** — service Maven plugin
- **asciidoc-api-svc** — AsciiDoc API microservice
- **cucumber-gen-svc** — Cucumber code generation microservice
- **mcp-svc** — MCP server implementation

Forward engineering transforms AsciiDoc specs into Cucumber test code:

```
scripts/forward-engineer.bat
```

Reverse engineering updates specs from existing test code:

```
scripts/reverse-engineer.bat <tag>
```

Both invoke the `sheep-dog-svc-maven-plugin` which calls the cloud services in sheep-dog-svc to perform the transformations.
