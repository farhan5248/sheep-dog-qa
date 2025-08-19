# CLAUDE.local.md

This file provides cross-repository coordination guidance for Claude Code when working with the complete sheep-dog ecosystem.

> **Note**: For detailed guidance, see the topic-specific files:
> - `CLAUDE.architecture.md` - System architecture and design patterns
> - `CLAUDE.development.md` - Development workflows and practices  
> - `CLAUDE.testing.md` - BDD/testing methodologies

## Repository Ecosystem

### Core Repositories
- **sheep-dog-qa**: QA specifications and cloud deployment (uses `sheep-dog-dev-svc-maven-plugin:1.29`)
- **sheep-dog-local**: Local development with Eclipse IDE (uses `sheep-dog-dev-maven-plugin:1.26-SNAPSHOT`) 
- **sheep-dog-cloud**: Cloud microservices (uses `sheep-dog-dev-svc-maven-plugin`)
- **sheep-dog-ops**: Operations and release management (provides `sheep-dog-mgmt-maven-plugin`)

### Documentation Sites
- **sheep-dog-local.wiki**: Local development documentation
- **farhan5248.github.io**: Personal GitHub Pages site
- **sheepdogblog**: Sheep Dog methodology blog  
- **demingdriventesting**: Deming Driven Testing documentation
- **modularmonolith**: Architecture documentation

## Quick Reference

### Build Order
1. **sheep-dog-ops** → 2. **sheep-dog-qa** → 3. **sheep-dog-local** → 4. **sheep-dog-cloud**

### Plugin Usage by Repository
- **sheep-dog-qa**: `sheep-dog-dev-svc-maven-plugin:1.29` (no `-DrepoDir`)
- **sheep-dog-local**: `sheep-dog-dev-maven-plugin:1.26-SNAPSHOT` (requires `-DrepoDir`)
- **sheep-dog-cloud**: `sheep-dog-dev-svc-maven-plugin` (no `-DrepoDir`)

### Common Commands
```bash
# Universal build (run in each repo)
mvn clean install

# Forward engineering (sheep-dog-qa)
sheep-dog-specs/scripts/forward-engineer.bat

# Cross-repo transformation (sheep-dog-local)
mvn org.farhan:sheep-dog-dev-maven-plugin:uml-to-cucumber-guice \
  -DrepoDir=../../sheep-dog-qa/sheep-dog-specs/ -Dtags="sheep-dog-test"
```

## Cross-Repository Coordination

### Key Differences Between Repositories
- **Generated Code Location**: `src-gen/` directories in all repositories
- **Specifications Source**: Always in `sheep-dog-qa/sheep-dog-specs/src/test/resources/asciidoc/specs/`
- **Plugin Parameter Differences**: Only `sheep-dog-dev-maven-plugin` requires `-DrepoDir` parameter

### Maven Repository Configuration
- **GitHub Packages**: `maven.pkg.github.com/farhan5248/sheep-dog-qa`
- **Plugin Versions**: Explicitly defined in each repository's `pom.xml`
- **Java Version**: 21 (consistent across all repositories)

### Common Tags for Cross-Repository Work
- `sheep-dog-dev`: Development-focused specifications
- `sheep-dog-test`: Test automation specifications  
- `round-trip`: Round-trip engineering examples

### Coordination Best Practices
1. **Build order matters**: Follow dependency chain (ops → qa → local → cloud)
2. **Central specifications**: Edit specs in `sheep-dog-qa`, generate code in target repos
3. **Plugin compatibility**: Check `pom.xml` for explicit plugin versions
4. **Tag consistency**: Use same tags across repositories for coordinated transformations