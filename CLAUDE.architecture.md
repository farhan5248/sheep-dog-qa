# CLAUDE.architecture.md

This file provides architectural guidance for Claude Code when working with the sheep-dog ecosystem.

## System Architecture Overview

The sheep-dog ecosystem implements a **bidirectional transformation pipeline** for Domain-Specific Language (DSL) tooling, BDD/test automation, and documentation-driven development.

### Core Architectural Pattern

**Bidirectional Transformation Pipeline:**
```
AsciiDoc Documentation ↔ UML Model ↔ Test Code (Cucumber/JUnit)
```

This enables:
- **Documentation-driven development** (specs → tests)
- **Test-driven documentation** (tests → specs)  
- **Round-trip engineering** maintaining consistency between docs and code

### Repository Architecture

#### sheep-dog-qa (Specifications & Deployment)
- **Architectural Role**: Central specification repository and cloud deployment
- **Key Components**: 
  - AsciiDoc specifications in standardized directory structure
  - AWS EKS deployment configurations
  - GitHub Actions for CI/CD automation
  - Ollama integration for AI-enhanced development
- **Generated Artifacts**: Located in `sheep-dog-specs/src-gen/`
- **Cloud Integration**: AWS EKS, Kubernetes manifests, Docker containers

#### sheep-dog-local (Core Development Environment)
- **Architectural Role**: Complete local development toolchain with IDE integration
- **Key Components**:
  - **Core Transformation Engine** (`sheep-dog-dev`): Bidirectional converters
  - **Eclipse DSL Editor** (`sheepdogxtextplugin.parent`): IDE with content assist, validation, quick fixes
  - **Cucumber Language API** (`sheepdogcucumber.parent`): Xtext plugin for Cucumber files
  - **Semantic Validation** (`sheep-dog-test`): Language validation rules
- **Generated Artifacts**: Located in `src-gen/` directories across projects

#### sheep-dog-cloud (Microservices & Cloud-Native)
- **Architectural Role**: Cloud-native microservices for transformation services
- **Key Components**:
  - **Spring Boot REST APIs**: Transformation endpoints
  - **JMS Messaging**: Asynchronous processing
  - **MySQL Integration**: Persistent storage for models
  - **Docker Containers**: Containerized deployment
  - **Kubernetes Manifests**: Cloud orchestration
- **Service Architecture**: RESTful microservices with database persistence

#### sheep-dog-ops (Operations & Release Management)
- **Architectural Role**: DevOps tooling and release automation
- **Key Components**:
  - **Custom Maven Plugin** (`sheep-dog-mgmt-maven-plugin`): Handles Xtext project releases
  - **GitHub Actions Integration**: Centralized workflow definitions
- **Purpose**: Manages release processes where standard Maven release plugin doesn't work

### Maven Plugin Architecture

#### Plugin Separation by Deployment Model

**sheep-dog-dev-maven-plugin** (Local Development)
- **Usage**: sheep-dog-local repository
- **Characteristics**: 
  - Requires `-DrepoDir` parameter for cross-repository transformations
  - File-based processing
  - Direct Maven execution

**sheep-dog-dev-svc-maven-plugin** (Service-Oriented)
- **Usage**: sheep-dog-qa, sheep-dog-cloud repositories  
- **Characteristics**:
  - No `-DrepoDir` parameter (handles repositories automatically)
  - Service-based processing
  - REST API integration

### Transformation Goals Architecture

**Input → UML Conversion:**
- `asciidoctor-to-uml`: AsciiDoc specifications → UML model
- `cucumber-to-uml`: Cucumber features → UML model

**UML → Output Generation:**
- `uml-to-cucumber`: UML → Cucumber tests (plain Java)
- `uml-to-cucumber-spring`: UML → Cucumber tests with Spring DI
- `uml-to-cucumber-guice`: UML → Cucumber tests with Guice DI
- `uml-to-junit-spring`: UML → JUnit tests with Spring DI
- `uml-to-junit-guice`: UML → JUnit tests with Guice DI
- `uml-to-asciidoctor`: UML → AsciiDoc documentation

### Tag-Based Processing Architecture

**Processing Filter System:**
- `sheep-dog-dev`: Development-focused specifications
- `sheep-dog-test`: Test automation specifications  
- `round-trip`: Round-trip engineering examples

Tags enable:
- **Selective Processing**: Filter transformations by context
- **Multi-Context Support**: Same repository, different processing targets
- **Incremental Development**: Process subsets during development

### Documentation Site Architecture

**GitHub Pages Integration:**
- **farhan5248.github.io**: Personal site with repository listings
- **sheepdogblog**: Methodology blog using Jekyll
- **demingdriventesting**: Deming Driven Testing documentation
- **modularmonolith**: Architecture documentation

### Eclipse IDE Integration Architecture

**Xtext Framework Components:**
1. **Grammar Definition**: Custom DSL syntax
2. **Content Assist**: Context-aware suggestions
3. **Validation Engine**: Real-time error checking
4. **Quick Fixes**: Automated problem resolution
5. **Code Generation**: Template-based artifact creation
6. **Syntax Highlighting**: Custom language coloring

### Dependency Architecture

**Maven Repository Strategy:**
- **Primary Repository**: GitHub Packages (`maven.pkg.github.com/farhan5248/sheep-dog-qa`)
- **Plugin Versioning**: Explicit versions in POM files, no command-line versions
- **Cross-Repository Dependencies**: Managed via `repoDir` parameter (dev plugin only)

**Technology Stack:**
- **Java Version**: 21 (consistent across all repositories)
- **Build System**: Maven with custom plugins
- **Dependency Injection**: Spring, Guice, or plain Java
- **Test Frameworks**: Cucumber, JUnit
- **Documentation**: AsciiDoc with Asciidoctor
- **IDE Integration**: Eclipse with Xtext
- **Cloud Platform**: AWS EKS with Kubernetes