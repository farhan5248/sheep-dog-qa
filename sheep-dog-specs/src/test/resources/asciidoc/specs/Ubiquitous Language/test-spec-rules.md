# Test Spec Refactoring Rules

## Two Categories of Tests

### 1. Grammar Tests (Structure / Class-level)
- Files: Grammar StepObjectRef Fragments, Grammar StepDefinitionRef Fragments, Grammar Phrase Fragments
- Describe the structure of the language itself — how types decompose, what fragments exist
- Use UML template vocabulary from `uml-overview.md`: "assignment", "fragment", "type", "scope"
- **No changes needed**

### 2. Non-Grammar Tests (Values / Object-level)
- Files: Validation, Quickfixes, Proposals, Code Generation, Grammar Long Names
- Make statements about specific values at specific nodes in document instances
- Use the generic word "node" instead of grammar terminology
- **These need refactoring**

## Step Anatomy (Non-Grammar Tests)

Every test step follows this pattern:

```
component  path/to/object  object-type  path/to/node  node-type  state
```

Example:
```
The spec-prj project src/.../Process2.asciidoc file TestSuite/1/TestCase/1/testStepList node is created as follows
```

| Segment | Example | Role |
|---|---|---|
| component | `spec-prj project` | Identifies the component |
| path/to/object | `src/.../Process2.asciidoc` | Path to the file/object |
| object-type | `file` | Type of object (file, action, popup, annotation, etc.) |
| path/to/node | `TestSuite/1/TestCase/1/testStepList` | AST node path using grammar type names and assignment names |
| node-type | `node` | Always "node" for non-grammar tests |
| state | `is created as follows` | The action/assertion |

## Node Path Format

Node paths use grammar names directly from `SheepDog.xtext`:

- **Type names** are PascalCase: `TestSuite`, `TestCase`, `TestSetup`, `Row`, `Cell`
- **Assignment names** are camelCase: `testStepList`, `testDataList`, `cellList`, `name`, `content`
- **Positions** are 1-based integers
- Format: `TypeName/index/assignmentName` or `TypeName/index/assignmentName/TypeName/index/...`

Examples:
- `TestSuite/1` — first test suite
- `TestSuite/1/TestCase/1` — first test case in first test suite
- `TestSuite/1/TestCase/1/testStepList` — the test step list of that test case
- `TestSuite/1/TestCase/1/testStepList/1/table/Row/1/cellList` — cell list of first row of first test step's table

## Step Roles

- **Given** — builds the document structure. Each step specifies the node path and node type it's creating.
- **When** — selects a node to process (equivalent to user clicking in the IDE). The Node Path table is correct as-is.
- **Then** — asserts values/results at the selected node.

## Table Rules

### Key Principle
Each step talks about ONE node at a specific path. Table headers are ONLY the non-list assignments of that node's type.

### Non-list Assignments (=) → Table Headers
These become column headers in a two-row table (row 1 = names, row 2 = values).

Example for `TestSuite/1/TestCase/1 node`:
```
TestCase:
    name=Phrase
    description=Description?
    testStepList+=TestStep*   ← list, NOT a header
    testDataList+=TestData*   ← list, NOT a header
```
Valid headers: `| Name | Description |`

### List Assignments (+=) → Separate Steps
List assignments get their own step with the path extended to the assignment name.

Example: `testStepList+=TestStep*` on TestCase becomes:
```
...TestSuite/1/TestCase/1/testStepList node is created as follows
```

### List Table Format
For list assignments, the first row is the header and remaining rows are identifiers. The header name is usually `Name` (the unique identifier assignment on the list item type).

Example for cellList:
```
|===
| Name
| N1
| N2
|===
```

### Nodes Without Non-list Assignments
Some types have no non-list assignments (e.g., `Row` only has `cellList+=Cell+`). These cannot be listed in a table. Each instance gets its own step with a positional path.

Example — each row is a separate step:
```
...table/Row/1/cellList node is created as follows
|===
| Name
| N1
| N2
|===

...table/Row/2/cellList node is created as follows
|===
| Name
| V1
| V2
|===
```

## Derived Names

`Test Step Full Name` is a derived name (not a direct grammar assignment). It is composed of `stepObjectName` + `stepDefinitionName`. This needs to be documented in `uml-overview.md`.

## What's Wrong Today

1. Given steps use vague terms like `test step list assignment` instead of explicit node paths like `TestSuite/1/TestCase/1/testStepList node`
2. Table headers use made-up names (`Test Step Full Name`, `Row Cell List`, `Text Content`) instead of actual grammar assignment names
3. Different node levels are mixed in a single table (e.g., TestStep assignments and Row assignments in the same step)
4. List assignments are represented as CSV values in cells instead of as separate rows or separate steps

## Refactoring Strategy

Each phase follows the cycle: change qa specs → generate in local repo → update impl → run tests.

### Phase 1: Split list vs non-list assignments
Duplicate test steps that currently mix list and non-list assignments in one table. Split them into separate steps — one for non-list assignments (two-row table) and one for each list assignment. For example, a step with both `Test Step Full Name` and `Row Cell List` becomes two steps: one for the test step and one for the row's cellList.

### Phase 2: Add "node" to step names
Replace grammar terminology like "assignment" with the generic word "node" in all non-grammar test step names. E.g., `test step list assignment` → `test step list node`.

### Phase 3: Add node paths and update impl code
Add explicit node paths to step names (e.g., `TestSuite/1/TestCase/1/testStepList node`). Update implementation code to navigate using the node path from the step name instead of inferring it from header names or using defaults. This phase also handles splitting cellList CSV values into separate rows/steps.

