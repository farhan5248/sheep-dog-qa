# Test Object Implementation Patterns

Test object implementations (`{ObjectName}{ObjectType}Impl`) bridge Cucumber step definitions to grammar model operations. Their behavior is determined by two dimensions:

- **Test Set**: Grammar (creating/modifying/asserting grammar elements) vs Issues (validation, proposals, quickfixes)
- **Object Type**: Edge (Action — buffers parameters in `properties`) vs Vertex (File, Popup, Annotation — operates directly on model/dialog)

## Pattern Summary

### Grammar Set

| # | Pattern | get | set |
|---|---------|-----|-----|
| 1 | Node {Part} {Param} | If Param=NodePath → setCursorAtNode. If Param=State → return state/listToString. Otherwise → assert{Type}{Assignment} | If Param=NodePath → createNodeDependencies. Otherwise → add{Type}With{Assignment} |
| 2 | Document create/get | `cursor = testProject.getTestDocument(getFullNameFromPath()); return...` | `add{Type}WithFullName(getFullNameFromPath())` |
| 3 | Action navigate + add (edge only) | N/A | Store to properties, then in "performed": navigateToDocument + navigateToNode + add{Type}With{Assignment} |

### Issues Set

| # | Pattern | get | set |
|---|---------|-----|-----|
| 4 | Type dispatch (edge only) | N/A | Navigate, instanceof chain → {Type}IssueDetector.validate / {Type}IssueResolver.correct / suggest{Assignment}{Scope}() |
| 5 | Dialog read/write (vertex) | Return dialog string or listToString(dialog) | Assign to dialog variable |
| 6 | Proposal read/write (vertex) | Iterate dialog list, match by Id, return field | Append new {Language}IssueProposal to dialog list |

### Cross-cutting

| # | Pattern | Description |
|---|---------|-------------|
| 7 | Store property (edge only) | `properties.put("Key", keyMap.get("Key"))` — edge classes buffer params for later consumption |

## Pattern × Dimension Matrix

|  | Grammar + Vertex | Grammar + Edge | Issues + Vertex | Issues + Edge |
|--|-----------------|----------------|-----------------|---------------|
| 1. Node {Part} {Param} | File impls | — | File impls | — |
| 2. Document create/get | File impls | — | File impls | — |
| 3. Action navigate + add | — | Action impls | — | — |
| 4. Type dispatch | — | — | — | Validate/Apply/ListProposals/ListQuickfixes Action impls |
| 5. Dialog read/write | — | — | Annotation, Popup impls | — |
| 6. Proposal read/write | — | — | Popup impls | — |
| 7. Store property | — | Action impls | — | Action impls |

## Edge vs Vertex Lifecycle

**Edge (Action)**: set{Type}{Assignment} buffers into `properties` → set{StateDesc} consumes from `properties` and performs the operation.

**Vertex (File, Popup, Annotation)**: get/set{Type}{Assignment} and get/set{StateDesc} operate directly on the document model or dialog state. No property buffering.
