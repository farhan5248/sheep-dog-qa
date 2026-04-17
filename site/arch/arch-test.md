# Test Object Architecture — Root

This file describes the generic `TestObject` base class and the framework behavior it provides to every project. It is the root of the TestObject hierarchy; bounded-context-specific behavior lives in sibling files.

- Grammar / EMF-based projects — see [arch-test-emf.md](arch-test-emf.md).
- Maven plugin projects — see [arch-test-maven.md](arch-test-maven.md).
- Handcrafted impl class contract — see [../impl/impl-test-impl.md](../impl/impl-test-impl.md).

## Hierarchy by bounded context

`TestObject` is generic. Each bounded context gets a specialized subclass. Every impl class extends the project's bounded-context subclass, never `TestObject` directly.

```
TestObject (root)
├── MavenTestObject      — Maven plugin projects (darmok, svc-maven-plugin, mgmt)
├── RESTTestObject       — RESTful service projects
├── MCPTestObject        — MCP server projects
└── EMFTestObject        — EMF projects (grammar)
    └── XtextTestObject  — Xtext projects
        └── LSPTestObject       — LSP projects
            ├── EclipseTestObject  — Eclipse projects
            └── VSCodeTestObject   — VSCode projects
```

The subclass carries context-specific helpers. `MavenTestObject` holds Mojo execution and file I/O. `EMFTestObject` holds cursor/path navigation against an EMF model. Subclasses further down the chain (Xtext → LSP → Eclipse/VSCode) layer additional capabilities on top.

## Framework behavior

`TestObject` provides the step entry points the Cucumber glue calls into. Each entry point:

1. Stashes `partDesc`, `partType`, `stateType`, `stateDesc` onto the shared `properties` map.
2. Dispatches via reflection to a public method on the concrete impl, named `{operation}{Section}{Field}` where the fragments are PascalCased from the step arguments.
3. Interprets the return value against the `TestState` enum when the step is an assertion.

### Step entry points

| Method | Used for | Variant with `DataTable` | Variant with docstring |
|---|---|---|---|
| `assertVertexStep` | Vertex assertion (get) | ✅ | ✅ |
| `setVertexStep` | Vertex mutation (set) | ✅ | ✅ |
| `doEdgeStep` | Edge action | ✅ | ✅ |

The variants drive three helpers: `processInputOutputsStepDefinitionRef` (existence gate), `processInputOutputsTable` (content inspection per column), `processInputOutputsText` (content inspection as a single `Content` field).

### stepDefinitionRef vs table/docstring (two separate concerns)

Every step-level dispatch runs `processInputOutputsStepDefinitionRef`. It calls `{operation}{Section}{StateDesc}` on the impl as an **existence gate** — the return value is mapped through `TestState`:

| Return value | Mapped state |
|---|---|
| `null` | `Absent` |
| `""` (empty string) | `Empty` |
| anything else | `Present` |

The stateDesc words (`Present`, `Absent`, `Empty`, `created as follows`, `is readable`, …) communicate *intent* to the test reader. They do **not** branch the framework logic — dispatch is always the same. This means a file-existence gate is the same code for every file-like object in any project.

When the step carries a `DataTable` or docstring, `processInputOutputsTable` / `processInputOutputsText` runs in addition. This is **content inspection** — column-specific getters (`getLevel`, `getCategory`, `getContent`, etc.) read specific attributes, and these differ per impl. The table columns or docstring body carry the comparison values.

Nothing in the test code should skip the existence gate. If a particular stateDesc can't be resolved, that is an impl or spec problem, not a framework bypass.

### Negative test handling

`stateType` carries the grammatical form of the step phrase:

| stateType | Framework behavior |
|---|---|
| `is`, `will be` | Positive assertion / create |
| `isn't`, `won't be` | Negative assertion for `get`; **delete** for `set` |

For **get** operations the framework flips the assertion (`assertEquals` → `assertNotEquals`, `assertNotNull` → `assertNull`) automatically. Impls never need to branch on the negation — they compute the actual value, the framework handles the comparison direction.

For **set** operations `isn't` communicates **action intent** (delete), not assertion negation. Subclass helpers like `MavenTestObject.createOrDeleteFile(Path)` consume `stateType` from `properties` to pick the right branch.

### TestState enum

`TestState.{Absent, Empty, Present, Any}` carries the existence-gate vocabulary. `Any` is a wildcard — when a table cell reads `Any` for a column, that column is skipped entirely for that row. The framework uses `TestState.contains(String)` to decide whether a stateDesc is being used as an existence keyword (map through the enum) or as a free-form content value (compare as-is).

### Properties map

`TestObject.properties` is a static `HashMap<String, Object>` shared across a scenario. The framework uses it both as a parameter buffer (action steps that need to carry values across multiple step invocations, like edge actions) and as a scenario-scoped cache (resolved paths, loaded mojo logs, stateType for the current step). Call `TestObject.reset()` between scenarios.

### Reflection helpers

`setField(Object, String, String)` and `findField(Class, String)` are generic reflection utilities on the base. They walk the inheritance chain to locate a field by name, coerce the string value to the field's declared type (`String`, `int`/`Integer`, `boolean`/`Boolean`), and assign it. Subclasses use these to hydrate objects from properties maps — `MavenTestObject` applies this pattern to inject mojo parameters from `mojo-defaults.properties` overrides.

## Sample

The canonical `TestObject.java` is in [../impl/samples/TestObject.java](../impl/samples/TestObject.java). Every project's `TestObject.java` must be byte-identical to this sample.
