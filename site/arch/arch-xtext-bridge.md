# Bridge Pattern & Component Dependencies

This document describes how the Xtext plugins integrate with the sheep-dog-grammar business logic layer using the Bridge Pattern.

## Inter-Component Dependencies

```
sheep-dog-grammar (business logic jar)
    ↑ consumed by
sheepdogxtextplugin (core) ←→ sheepdogxtextplugin.ide (shared IDE logic)
    ↓                              ↓
sheepdogxtextplugin.ui         xtextasciidocplugin.ide + .vscode
(Eclipse-specific)             (LSP-based VS Code)
```

**Key Relationships:**
- **sheep-dog-grammar → Xtext plugins**: Business logic (IssueDetector, IssueResolver) consumed by both Eclipse and VS Code implementations
- **Core → IDE modules**: Grammar and validation shared; IDE modules add platform-specific integration
- **Eclipse .ui ≠ VS Code .vscode**: Different integration approaches (see [arch-xtext-ide.md](arch-xtext-ide.md))

## Bridge Pattern Architecture

The implementation uses the Bridge Pattern to separate domain model from Xtext/EMF framework:

```
Interface Layer (sheep-dog-grammar)     ← Framework-independent
    ↓ implements
Implementation Layer (*Impl classes) ← Xtext/EMF wrappers
    ↓ wraps
Generated EMF Objects                ← Xtext auto-generated
```

**Benefits:**
- Business logic in `org.farhan.dsl.lang` and `org.farhan.dsl.issues` has no Xtext dependencies
- Same validation/resolution logic reused across Eclipse, CLI, and cloud contexts
- Testable without Xtext infrastructure

## Interface-Based Domain Model

**Decision:** Framework-independent interfaces (`I*`) separate from Xtext implementation.

**Rationale:** Enables reuse across Eclipse IDE, command-line, and cloud services. All `*IssueDetector` and `*IssueResolver` classes work with interfaces, never EMF objects directly.

## Lazy Parent Initialization

**Decision:** Parent relationships initialized lazily using EMF's `eContainer()` to avoid circular initialization and improve memory efficiency.


