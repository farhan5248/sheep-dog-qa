# Validation Architecture

This document describes the architectural decisions for the Xtext validation system.

## Three-Level Validation Strategy

**Decision:** Validation separated by scope and performance:

| Level | CheckType | Trigger | Use Case |
|-------|-----------|---------|----------|
| **FAST** | `CheckType.FAST` | Every keystroke | Syntax validation, element-level checks |
| **NORMAL** | `CheckType.NORMAL` | File save | Semantic validation, file-level checks |
| **EXPENSIVE** | `CheckType.EXPENSIVE` | On-demand/build | Cross-file reference validation |

**Rationale:** Responsive IDE experience - fast validations don't block UI, thorough validations run at appropriate times.

## Dual-Purpose Issue Classes

**Decision:** Same classes serve both validation and content assist:

| Class | Validation Role | Content Assist Role |
|-------|-----------------|---------------------|
| `*IssueDetector` | Validator finds problems | (not used) |
| `*IssueResolver` | QuickfixProvider applies fixes | ProposalProvider suggests values |

**Rationale:**
- Validation errors automatically have associated fixes
- Content assist suggests valid values, preventing errors before they occur
- Centralized business logic reduces code duplication

## Component-Based Code Organization

**Decision:** Organize by grammar component, not validation type.

**Pattern used:**
```
TestStep concerns grouped:
  - TestStepIssueDetector (all TestStep validations)
  - TestStepIssueResolver (all TestStep proposals/fixes)
  - TestStepIssueTypes (all TestStep error codes)
```

**Alternative not used:**
```
Validation type organization:
  - AllIssueDetectors in one package
  - AllIssueResolvers in one package
```

**Benefits:**
- High cohesion - all concerns for a grammar element in one place
- Natural alignment with grammar structure
- Clear ownership per grammar element

## Cross-References

- **Code patterns**: See [impl-xtext-eclipse.md](impl-xtext-eclipse.md) for validation examples
- **Class patterns**: See `site/uml/uml-class-*IssueDetector.md` files in each project
