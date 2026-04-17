# Test Object Architecture — Maven

Extends the root [arch-test.md](arch-test.md) with Maven-plugin-specific test scaffolding. Applies to projects whose impls exercise Mojos and the files the Mojos read or write, such as `darmok-maven-plugin`, `sheep-dog-svc-maven-plugin`, and `sheep-dog-mgmt-maven-plugin`.

## MavenTestObject

`MavenTestObject` extends `TestObject` and adds Mojo execution, properties-file-driven defaults, file I/O helpers, and log inspection.

### Mojo execution

`executeMojo(Class<? extends DarmokMojo>)` instantiates a Mojo via its no-arg constructor, wires the `MavenProject` / `baseDir`, applies parameter overrides from `properties` on top of the defaults loaded from `mojo-defaults.properties`, calls `execute()`, and captures any thrown exception in `properties` under `goal.exception` for a subsequent assertion step to pick up.

Field assignment uses the generic `TestObject.setField(Object, String, String)` reflection utility. This means any Mojo parameter — `String`, `int`, `boolean` — can be overridden from a scenario table without the base having to know the parameter list.

### mojo-defaults.properties

Each project ships a `src/test/resources/mojo-defaults.properties` file that lists every Mojo parameter and its default value. At `MavenTestObject` class-init time the file is read into a static `Properties`. During `executeMojo`, each key is applied in order: `properties.get(key)` override if set, else the defaults file value. A scenario that does not explicitly set a parameter gets the project default — this is why tests stay concise.

### File I/O helpers

| Helper | Role |
|---|---|
| `resolveFilePath()` | Resolves the current `object` relative to the base directory of the current `component`. Returns `null` if the base is unknown. |
| `createFile(Path)` | Creates parent directories and a placeholder file if it doesn't exist. No-op for `null`. |
| `deleteFile(Path)` | Deletes the file if present. No-op for `null`. |
| `createOrDeleteFile(Path)` | Dispatches on `stateType`: `isn't` → delete, anything else → create. Encodes Rule 5's action-intent semantics. |
| `writeFile(Path, String)` | Creates parents and writes content (null content becomes empty). |
| `getFileState(Path)` | Returns the raw file contents if the file exists, else `null`. Used as the existence-gate input — `null`/`""`/non-empty map to `Absent`/`Empty`/`Present`. |
| `getFileContent(Path)` | Returns the normalized content: `getFileState` result with `\r` stripped and trimmed. This is the canonical body-comparison helper and is what impls' `getContent(HashMap keyMap)` must delegate to (see [../impl/impl-test-impl.md](../impl/impl-test-impl.md)). |

### Log inspection

`getMojoLog(String prefix)` resolves the log directory (either a `log.dir` override or the component's `target/darmok`), finds the latest dated log file that matches the prefix, wraps it in `MojoLog`, and caches the result on `properties` keyed by `mojoLog.{prefix}`. Content-inspection steps then pull the cached `MojoLog` and query it by `Level` / `Category` / `Content`.

### Action vs assertion — stateType

The `stateType` property ("is" / "isn't" / "will be" / "won't be") drives two different things depending on the operation:

- **get** — the framework negates the assertion automatically (see root arch-test.md). No Maven-specific concern.
- **set** — Maven impls call `createOrDeleteFile(resolveFilePath())` which reads `stateType` from `properties` and picks delete vs create. Impls do not branch on `stateType` directly.

## Sample

The canonical `MavenTestObject.java` is in [../impl/samples/MavenTestObject.java](../impl/samples/MavenTestObject.java).
