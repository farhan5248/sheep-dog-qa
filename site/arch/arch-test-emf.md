# Test Object Architecture — EMF

Extends the root [arch-test.md](arch-test.md) with EMF-specific test scaffolding. Applies to projects whose impls manipulate an EMF model directly, such as `sheep-dog-grammar`.

## EMFTestObject

`EMFTestObject` extends `TestObject` and adds cursor/path navigation against an EMF `Resource`. The `cursor` property on `TestObject.properties` tracks the currently focused model element; impl methods advance the cursor by creating, navigating to, or asserting on model nodes.

### Scenario reset

`reset()` is `public static void` throughout the hierarchy — each project's `TestConfig` calls the reset appropriate to its bounded context. For EMF projects, `TestConfig` calls `EMFTestObject.reset()`, which chains `TestObject.reset()` and then restores the EMF factory singleton:

```java
public static void reset() {
    TestObject.reset();
    SheepDogFactory.instance = ISheepDogFactory.eINSTANCE;
}
```

This keeps every scenario isolated from factory stubbing done by earlier tests. Projects in other bounded contexts (Maven, REST, MCP, ...) whose scaffolding does not touch the grammar factory call `TestObject.reset()` directly and do not need this hide.

### Cursor lifecycle

A typical scenario moves the cursor through three stages:

1. `navigateToDocument()` — positions the cursor at the root of a named document (test suite or step object) inside the workspace `ITestProject`.
2. `navigateToNode(String path, boolean fallback)` — walks a slash-separated path from the document down to a target node. When `fallback` is true and the exact path is not found, the framework drops path segments from the front until a partial match resolves.
3. `createNodeDependencies(String path)` — walks the same path but creates any missing intermediate nodes along the way, ending with the cursor on the deepest created node.

`PathSegment` parses each path component. Segments whose type ends in `List` consume two parts (type + 1-based index); all other segments are scalar with an implicit index of 0.

### Add / assert / set helpers

`EMFTestObject` provides one helper per grammar element type the DSL defines:

| Category | Helpers |
|---|---|
| `add*` | `addCellWithName`, `addLineWithContent`, `addRowWithContent`, `addStepDefinitionWithName`, `addStepObjectWithFullName`, `addStepParametersWithName`, `addTable`, `addTestCaseWithName`, `addTestDataWithName`, `addTestSetupWithName`, `addTestStepWithFullName`, `addTestSuiteWithFullName`, `addTextWithContent` |
| `assert*` | `assertCellName`, `assertLineContent`, `assertRowContent`, `assertStepDefinitionName`, `assertStepDefinitionRefName`, `assertStepObjectName`, `assertStepObjectRefName`, `assertStepParametersName`, `assertTestDataName`, `assertTestStepContainerName`, `assertTestStepFullName`, `assertTestSuiteName` |
| `set*` | `setStepDefinitionName`, `setTestSuiteName` |
| cursor query | `getDescriptionFromCursor`, `getTableFromCursor` |

Each `add*` helper follows a consistent pattern: if the cursor is already on a node of the target type, walk up to the parent first, then create the new child via `SheepDogBuilder.create*`, then set the cursor to the new child. This lets the same helper be called repeatedly to build sibling children without the spec needing to track the cursor explicitly.

## Test Set × Object Type patterns

Test object implementations (`{ObjectName}{ObjectType}Impl`) bridge Cucumber step definitions to grammar model operations. Their behavior is determined by two dimensions:

- **Test Set**: Grammar (creating / modifying / asserting grammar elements) vs Issues (validation, proposals, quickfixes)
- **Object Type**: Edge (Action — buffers parameters in `properties`) vs Vertex (File, Popup, Annotation — operates directly on model / dialog)

### Grammar Set patterns

| # | Pattern | get | set |
|---|---------|-----|-----|
| 1 | Node {Part} {Param} | If Param=NodePath → setCursorAtNode. If Param=State → return state/listToString. Otherwise → assert{Type}{Assignment} | If Param=NodePath → createNodeDependencies. Otherwise → add{Type}With{Assignment} |
| 2 | Document create/get | `cursor = testProject.getTestDocument(getFullNameFromPath()); return...` | `add{Type}WithFullName(getFullNameFromPath())` |
| 3 | Action navigate + add (edge only) | N/A | Store to properties, then in "performed": navigateToDocument + navigateToNode + add{Type}With{Assignment} |

### Issues Set patterns

| # | Pattern | get | set |
|---|---------|-----|-----|
| 4 | Type dispatch (edge only) | N/A | Navigate, instanceof chain → {Type}IssueDetector.validate / {Type}IssueResolver.correct / suggest{Assignment}{Scope}() |
| 5 | Dialog read/write (vertex) | Return dialog string or listToString(dialog) | Assign to dialog variable |
| 6 | Proposal read/write (vertex) | Iterate dialog list, match by Id, return field | Append new {Language}IssueProposal to dialog list |

### Cross-cutting

| # | Pattern | Description |
|---|---------|-------------|
| 7 | Store property (edge only) | `properties.put("Key", keyMap.get("Key"))` — edge classes buffer params for later consumption |

### Pattern × Dimension Matrix

|  | Grammar + Vertex | Grammar + Edge | Issues + Vertex | Issues + Edge |
|--|-----------------|----------------|-----------------|---------------|
| 1. Node {Part} {Param} | File impls | — | File impls | — |
| 2. Document create/get | File impls | — | File impls | — |
| 3. Action navigate + add | — | Action impls | — | — |
| 4. Type dispatch | — | — | — | Validate/Apply/ListProposals/ListQuickfixes Action impls |
| 5. Dialog read/write | — | — | Annotation, Popup impls | — |
| 6. Proposal read/write | — | — | Popup impls | — |
| 7. Store property | — | Action impls | — | Action impls |

### Edge vs Vertex lifecycle

**Edge (Action)**: `set{Type}{Assignment}` buffers into `properties` → `set{StateDesc}` consumes from `properties` and performs the operation.

**Vertex (File, Popup, Annotation)**: `get/set{Type}{Assignment}` and `get/set{StateDesc}` operate directly on the document model or dialog state. No property buffering.

## Sample

The canonical `EMFTestObject.java` is in [../impl/samples/EMFTestObject.java](../impl/samples/EMFTestObject.java).
