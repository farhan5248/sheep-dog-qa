# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with the sheep-dog-qa repository.

> **📚 Complete Documentation**: See the topic-specific files in this repository:
> - `CLAUDE.local.md` - Cross-repository coordination
> - `CLAUDE.architecture.md` - System architecture & design patterns
> - `CLAUDE.development.md` - Development workflows & practices  
> - `CLAUDE.testing.md` - BDD/testing methodologies

## Repository Overview

**sheep-dog-qa** is the **central QA and specifications repository** with cloud deployment capabilities for the sheep-dog ecosystem.

### Key Components
- **sheep-dog-specs**: Core specification and documentation project
- **AWS/EKS Integration**: Cloud deployment configurations
- **GitHub Actions**: CI/CD automation workflows  
- **Ollama Integration**: AI-enhanced development support

### Maven Plugin Used
- **Plugin**: `sheep-dog-dev-svc-maven-plugin:1.29`
- **Key Feature**: Does NOT require `-DrepoDir` parameter (auto-handles repositories)

## QA Repository Commands

### Forward Engineering (Generate UML from Specifications)
```bash
# Run from sheep-dog-specs directory
scripts/forward-engineer.bat

# Or manually:
mvn clean
mvn org.farhan:sheep-dog-dev-svc-maven-plugin:asciidoctor-to-uml -Dtags="sheep-dog-dev"
mvn org.farhan:sheep-dog-dev-svc-maven-plugin:asciidoctor-to-uml -Dtags="sheep-dog-test"
mvn org.farhan:sheep-dog-dev-svc-maven-plugin:asciidoctor-to-uml -Dtags="round-trip"
```

### Reverse Engineering (Update Specifications from Code)
```bash
# Run from sheep-dog-specs directory  
scripts/reverse-engineer.bat <tag_name>

# Or manually:
mvn clean
mvn org.farhan:sheep-dog-dev-svc-maven-plugin:uml-to-asciidoctor -Dtags="<tag_name>"
```

## QA Repository-Specific Features

### Specification Management
- **Primary Location**: `sheep-dog-specs/src/test/resources/asciidoc/specs/`
- **Step Definitions**: `sheep-dog-specs/src/test/resources/asciidoc/stepdefs/`
- **Generated Output**: `sheep-dog-specs/src-gen/` (target for other repositories)
- **Automation Scripts**: `sheep-dog-specs/scripts/` for engineering workflows

### Ollama Integration
AI-enhanced development with custom model:
```bash
ollama create qakb -f ./Modelfile
ollama run qakb
```

### Container & Deployment Support
- **Cheatsheet**: See `cheatsheet.txt` for Docker, Kubernetes, and Minikube commands
- **AWS Scripts**: `sheep-dog-specs/scripts/aws-*` for EKS cluster management
- **Kubernetes**: Deployment manifests for cloud testing

### GitHub Actions Workflows
- **forward-engineer.yml**: Automated specification processing
- **AWS deployment workflows**: Cloud testing and deployment automation
- **Cross-repository coordination**: Triggers for dependent repositories

## Tags Used in This Repository
- `sheep-dog-dev`: Development-focused specifications
- `sheep-dog-test`: Test automation specifications  
- `round-trip`: Round-trip engineering validation examples

## Central Coordination Role
This repository serves as the **specification hub** for the entire sheep-dog ecosystem:
- **Source of Truth**: All specifications originate here
- **Cross-Repository**: Other repos reference these specs for code generation
- **Cloud Deployment**: Provides deployment configurations for the ecosystem
- **Documentation Hub**: Hosts comprehensive CLAUDE.md documentation suite