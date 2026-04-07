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
