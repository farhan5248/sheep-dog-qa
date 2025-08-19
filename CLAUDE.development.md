# CLAUDE.development.md

This file provides development workflow guidance for Claude Code when working with the sheep-dog ecosystem.

## Development Workflows

### Cross-Repository Development Process

**Build Order (Dependency Chain):**
1. **sheep-dog-ops** (management plugin)
2. **sheep-dog-qa** (specifications and testing used for BDD)
3. **sheep-dog-local** (core libraries)
4. **sheep-dog-cloud** (service layer)

**Universal Build Command** (run in each repository):
```bash
mvn clean install
```

### Forward Engineering Workflow (Documentation → Code)

**Step 1: Generate UML from Specifications**
```bash
# In sheep-dog-qa/sheep-dog-specs
scripts/forward-engineer.bat

# Or manually:
mvn clean
mvn org.farhan:sheep-dog-dev-svc-maven-plugin:asciidoctor-to-uml -Dtags="sheep-dog-dev"
mvn org.farhan:sheep-dog-dev-svc-maven-plugin:asciidoctor-to-uml -Dtags="sheep-dog-test"
mvn org.farhan:sheep-dog-dev-svc-maven-plugin:asciidoctor-to-uml -Dtags="round-trip"
```

**Step 2: Generate Code from UML**
```bash
# In sheep-dog-local/sheep-dog-test (or corresponding test project)
scripts/forward-engineer.bat

# Or manually:
mvn clean  
mvn org.farhan:sheep-dog-dev-maven-plugin:uml-to-cucumber-guice -DrepoDir=../../sheep-dog-qa/sheep-dog-specs/ -Dtags="sheep-dog-test"
```

### Reverse Engineering Workflow (Code → Documentation)

**When to Use:**
- Modify generated code in any repository's `src-gen/` directory
- Update specifications to reflect code changes
- Maintain synchronization between code and documentation

**Process:**
1. Modify generated code in `src-gen/` directory
2. Run reverse engineering: `sheep-dog-qa/sheep-dog-specs/scripts/reverse-engineer.bat <tag_name>`
3. Updated specifications appear in AsciiDoc files

### Eclipse IDE Development Workflow

**Setup Process:**
1. Import all projects from sheep-dog-local into Eclipse workspace
2. Build all projects: **Run As > Maven install** 
3. Run Xtext projects: Right-click `sheepdogxtextplugin` → **Run As > Eclipse Application**
4. Install plugin from `sheepdogxtextplugin.repository/target/` archive
5. Edit specifications with full IDE support

**IDE Features Available:**
- **Content Assist**: Context-aware code completion
- **Validation**: Real-time error checking as you type
- **Quick Fixes**: Automated problem resolution
- **Syntax Highlighting**: Custom language coloring
- **Code Generation**: Template-based artifact creation

### Cloud Service Development Workflow

**Local Development:**
1. Start local services: `docker compose up -d` (uses `docker/compose.yaml`)
2. Test REST endpoints for transformations
3. Develop using Spring Boot with hot reload

**Cloud Deployment:**
1. Build Docker images using Kubernetes Maven plugin
2. Deploy using Kubernetes manifests in `kubernetes/` directories
3. Test in cloud environment with full service stack

### Maven Plugin Development Guidelines

**Plugin Version Management:**
- **Explicit Versions**: Always specify plugin versions in POM files
- **Command Line**: Never specify versions in script commands (let Maven resolve from POM)
- **Consistency**: Ensure compatible plugin versions across repositories

**Plugin Parameter Guidelines:**
- **sheep-dog-dev-maven-plugin**: Requires `-DrepoDir` parameter for cross-repository work
- **sheep-dog-dev-svc-maven-plugin**: Does NOT use `-DrepoDir` parameter (auto-handles repositories)

### Working with Multiple Plugin Versions

**Cross-Repository Transformations:**
```bash
# Generate code in sheep-dog-local using specs from sheep-dog-qa
mvn org.farhan:sheep-dog-dev-maven-plugin:uml-to-cucumber-guice \
  -DrepoDir=../../sheep-dog-qa/sheep-dog-specs/ \
  -Dtags="sheep-dog-test"
```

**Dependency Management:**
- All repositories use GitHub Packages: `maven.pkg.github.com/farhan5248/sheep-dog-qa`
- Plugin versions may differ between repositories (check each `pom.xml`)

### GitHub Actions Integration

**Workflow Types:**
1. **Release Workflows**: Run Maven release plugin on `main` branch (named after Maven modules)
2. **Snapshot Workflows**: Run `mvn clean deploy` on `develop` branch (named after Git repos)
3. **Reusable Workflows**: Centralized in `sheep-dog-ops` repository

**Shared Workflow Components:**
- `deploy.yml`: Deployment automation
- `merge.yml`: Branch merge automation  
- `release.yml`: Release process automation
- `snapshot.yml`: Snapshot build automation
- `snapshot-docker.yml`: Docker snapshot builds

### Development Best Practices

**Build Process:**
1. **Always build dependencies first**: Follow the dependency chain order
2. **Clean builds**: Use `mvn clean install` for reliable builds
3. **Version compatibility**: Ensure compatible plugin versions when working across repositories

**Code Generation:**
1. **Generated code location**: Always check `src-gen/` directories for output
2. **Don't edit generated code manually**: Use reverse engineering to update specs instead
3. **Tag-based filtering**: Use appropriate tags (`-Dtags="tag_name"`) for transformation scope

**Cross-Repository Work:**
1. **Use `repoDir` parameter**: When working with dev plugin across repositories
2. **Specification editing**: Edit AsciiDoc files in `sheep-dog-qa/sheep-dog-specs/src/test/resources/asciidoc/specs/`
3. **Maintain synchronization**: Run forward/reverse engineering to keep code and docs in sync

**IDE Development:**
1. **Eclipse workspace**: Import all related projects for full context
2. **Plugin testing**: Use separate Eclipse instance for plugin development
3. **Hot reload**: Leverage Spring Boot devtools for rapid development cycles

### Version Control Strategy

**Branch Management:**
- `main`: Stable releases with Maven release plugin
- `develop`: Ongoing development with snapshot deployments
- Feature branches: Use for isolated feature development

**Commit Strategy:**
- **One commit per GitHub issue**: Each GitHub issue gets exactly one commit
- **Always amend commits**: When working on the same issue, amend to the existing commit instead of creating new commits
- **New commits only for new issues**: Only create new commits when starting work on a different GitHub issue
- **Issue-based commit messages**: For new commits, use the GitHub issue title/description as the commit message
- Separate commits for generated vs. manual code changes when they're different issues
- Tag releases consistently across repositories

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

**How to Specify New Commit Message:**
When starting work on a new GitHub issue, tell Claude Code:
- "Create a new commit with message: `<GitHub issue title>`"
- "New commit using issue: `<issue title/description>`"
- "Start new issue commit: `<message from GitHub issue>`"

### Debugging and Troubleshooting

**Common Issues:**
1. **Plugin version mismatches**: Check POM files for explicit versions
2. **Missing repoDir**: Ensure dev plugin includes `-DrepoDir` parameter
3. **Generated code conflicts**: Use clean builds and check `src-gen/` directories
4. **Eclipse plugin issues**: Rebuild and reinstall plugin archive

**Debug Techniques:**
- Use Maven debug mode: `mvn -X` for verbose output
- Check plugin execution: Verify correct plugin and version being used
- Validate transformations: Compare before/after states of generated code