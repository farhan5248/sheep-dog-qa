# Test Object Impl Class Contract

This file specifies the handcrafted contract every `{ObjectName}{ObjectType}Impl` class must follow. It is the implementation-side counterpart to the framework described in [../arch/arch-test.md](../arch/arch-test.md) and its context-specific siblings [arch-test-emf.md](../arch/arch-test-emf.md) and [arch-test-maven.md](../arch/arch-test-maven.md).

## Impl class contract

### Extend the bounded-context TestObject

An impl class must extend the TestObject subclass for its project's bounded context, never `TestObject` directly. The subclass is chosen from the hierarchy in [../arch/arch-test.md](../arch/arch-test.md).

| Project kind | Base class |
|---|---|
| Maven plugin (darmok, svc-maven-plugin, mgmt) | `MavenTestObject` |
| EMF model (grammar) | `EMFTestObject` |
| RESTful service | `RESTTestObject` |
| MCP server | `MCPTestObject` |
| Xtext language | `XtextTestObject` (which extends EMFTestObject) |
| LSP language server | `LSPTestObject` (which extends XtextTestObject) |
| Eclipse plugin | `EclipseTestObject` (which extends LSPTestObject) |
| VSCode plugin | `VSCodeTestObject` (which extends LSPTestObject) |

### All methods are public

Impl classes expose **only** public methods. No private, protected, or package-private methods. The framework locates impl methods via `Class.getMethod(...)`, which returns public methods only — anything non-public is invisible to the dispatch.

If a piece of logic feels like it wants to be private, that is a signal it does not belong in the impl. Move it to:

- the bounded-context `TestObject` subclass, if it is reusable across impls in the same context;
- the `TestObject` base, if it is context-free;
- or the production code under `src/main`, if it is production behavior masquerading as test scaffolding.

### Override only interface methods, with explicit @Override

Every impl implements a generated interface such as `ITestObjectFile` or `ITestObjectGoal`. The impl must:

- implement every method declared on the interface, each annotated with `@Override`;
- not declare any method beyond the interface — no helpers, no extras;
- not rely on silent inheritance — every method the impl exposes must carry `@Override` explicitly. Inheriting an interface method from a superclass without re-declaring it here is a Rule 2 violation.

Impls are **pure thin wrappers**. Each method body calls one or two helpers on the base class, maps `HashMap keyMap` entries onto those helpers, and returns. No branching on `stateType`, no file-content normalization, no model traversal inlined.

### Base helpers are `protected final`

To enforce the thin-wrapper contract from the base side, every helper on `EMFTestObject` / `MavenTestObject` / other context subclasses that is called from impls is declared `protected final`. This guarantees:

- Impls can reach the helpers (protected, same-package-or-subclass access).
- Impls cannot override them (final), so a stray override on the impl side is a compile error rather than silent divergence.

Public methods on the base exist only for step entry points that the Cucumber glue calls directly (`assertVertexStep`, `doEdgeStep`, `setVertexStep` on `TestObject`).

## stepDefinitionRef vs table/docstring

(Background: [../arch/arch-test.md](../arch/arch-test.md) § *stepDefinitionRef vs table/docstring*.)

**Existence gate** — `get{Section}{StateDesc}(HashMap keyMap)` and its `set` counterpart. These are the methods the framework calls via `processInputOutputsStepDefinitionRef`. The framework maps the return value through `TestState`:

| Return | Meaning |
|---|---|
| `null` | Absent |
| `""` | Empty |
| any non-empty string | Present |

The impl for a file-like object simply returns the file body (or `null` if missing). This is **the same shape in every project** — for Maven-backed impls it is a one-liner delegating to `getFileContent(resolveFilePath())`.

**Content inspection** — per-column getters like `getContent`, `getLevel`, `getCategory`. These are what `processInputOutputsTable` and `processInputOutputsText` call. They differ per impl because the shape of what is being inspected differs (a file body vs a log entry vs a dialog field).

Do not conflate the two. The existence gate is boilerplate; the content inspection carries the domain-specific shape.

## Maven-scoped: getContent delegation

*Applies only to impls that extend `MavenTestObject`.*

Every Maven impl's `getContent(HashMap keyMap)` method is a one-liner that delegates to the base:

```java
@Override
public String getContent(HashMap<String, String> keyMap) {
    return getFileContent(resolveFilePath());
}
```

The `\r` stripping and trimming live on `MavenTestObject.getFileContent(Path)` — see [../arch/arch-test-maven.md](../arch/arch-test-maven.md). Impls must not perform their own `replaceAll("\r", "").trim()`. A `getContent` that does the stripping inline is a Rule 4 violation and must be refactored to delegate.

This rule is Maven-specific because only Maven projects currently deal with file-backed content in this shape. RESTTestObject / MCPTestObject will grow analogous normalization helpers when those contexts ship impls; this doc will be extended when they do.

## Samples

Canonical reference files live under [samples/](samples/):

- [samples/TestObject.java](samples/TestObject.java) — the root base. Every project's `src/test/java/org/farhan/common/TestObject.java` must match this byte for byte.
- [samples/EMFTestObject.java](samples/EMFTestObject.java) — the EMF-context subclass used by grammar.
- [samples/MavenTestObject.java](samples/MavenTestObject.java) — the Maven-context subclass used by darmok and svc-maven-plugin.
