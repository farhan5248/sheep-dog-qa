# Xtext Logging Architecture

This document describes how logging works across **sheep-dog-grammar** (SLF4J 2.x + Logback) to the Eclipse Runtime Workbench console, and why a custom bridging solution was required.

## Architecture Decision: Custom LoggerFactory with {Language}Logger

### Solution Overview

```
sheep-dog-grammar (jar)             sheepdogxtextplugin (OSGi bundle)
├── LoggerFactory                ├── {Language}Logger (org.slf4j.Logger)
│   └── checks NOPLoggerFactory  │   └── bridges SLF4J to Log4j
├── LoggerProvider (interface)   └── {Language}RuntimeModule
└── All classes use:                 └── sets LoggerFactory provider
    LoggerFactory.getLogger(...)
```

### Runtime Behavior

| Context | SLF4J Provider | Logger Used |
|---------|----------------|-------------|
| Maven tests | Logback available | Real SLF4J logger |
| Eclipse Runtime Workbench | NOPLoggerFactory (no provider) | {Language}Logger → Log4j |

### Design Decisions

1. **LoggerProvider interface**: Allows Eclipse plugin to inject its own logger implementation without sheep-dog-grammar depending on Log4j
2. **NOPLoggerFactory detection**: Checks when SLF4J falls back to its no-op implementation
3. **format() helper**: Converts SLF4J `{}` placeholders to Log4j format (Log4j 1.x doesn't support placeholders)

## Why This Architecture Was Chosen

### Root Cause: SLF4J 2.x + OSGi Incompatibility

SLF4J 2.x uses Java ServiceLoader to discover providers at runtime:
1. `LoggerFactory.getILoggerFactory()` triggers provider search
2. ServiceLoader looks for `META-INF/services/org.slf4j.spi.SLF4JServiceProvider`
3. **In OSGi**: Each bundle has isolated classloader - ServiceLoader can't see providers in other bundles
4. **Result**: SLF4J binds to NOPLoggerFactory and **cannot rebind**

### Approaches That Don't Work

| Approach | Why It Fails |
|----------|--------------|
| Add Logback to target platform only | Bundles in target platform don't load unless required in MANIFEST.MF |
| Require Logback bundles in MANIFEST.MF | SLF4J 2.x uses ServiceLoader which doesn't work reliably in OSGi |
| BundleActivator with JoranConfigurator (Vogella tutorial) | Bundle start order issue - SLF4J initializes before BundleActivator runs, binds to NOPLoggerFactory |
| Add slf4j.api to target platform | Doesn't solve bundle start order problem |
| Use slf4j-simple instead of Logback | Same bundle start order problem |
| Downgrade to SLF4J 1.x + Logback 1.2.x | Eclipse Orbit doesn't include Logback 1.2.x versions |
| Use Reload4j in sheep-dog-grammar | Log entries don't appear; also breaks other projects that rely on SLF4J |

### Key Constraints

1. **SLF4J 2.x + OSGi = Problematic** due to ServiceLoader + classloader isolation
2. **Bundle start order is critical** and hard to control in OSGi
3. **Vogella tutorial works for Eclipse RCP products** but not for testing plugins in Runtime Workbench
4. **Log4j works** in Eclipse OSGi (existing Xtext code uses it successfully)
5. **sheep-dog-grammar must remain SLF4J-based** for use in other modern projects

## When to Add Logging

**Java:**
- All manually edited Java classes that call sheep-dog-grammar methods must have loggers
- Generated Java classes (in src-gen/ and xtext-gen/) do NOT have loggers
- All methods that call sheep-dog-grammar business logic must include entry/exit debug logging for tracing execution flow. This includes:
  - Methods that directly call `*IssueDetector` or `*IssueResolver` classes
  - Methods that call `createAcceptor()` which delegates to `*Resolver` classes

**TypeScript:**
- All TypeScript modules that perform significant operations
- Extension activation/deactivation events
- Language server lifecycle events (start, stop, restart, health checks)
- Command execution
- Configuration changes
- Error conditions

See [impl-vscode-outputchannel.md](impl-vscode-outputchannel.md) for implementation patterns.

## Eclipse Plugin Exception Handling

Unlike sheep-dog-grammar business logic (which uses `throws Exception`), Xtext IDE integration methods must **catch and log** exceptions rather than propagating them.

**Why Xtext methods cannot throw exceptions:**
- Validator, quickfix, and proposal provider methods are called by Eclipse on the UI thread
- Throwing exceptions can crash the IDE or leave it unstable
- The Eclipse framework expects these methods to handle errors gracefully

**Pattern:**
- Catch exceptions from calls to sheep-dog-grammar methods
- Log using the appropriate format (see [arch-logging.md](arch-logging.md) for Log4j 1.2 patterns)
- Never rethrow - IDE must remain stable

**Exception:** `BadLocationException` in `IModification.apply()` can propagate - the quick fix framework handles this explicitly.

## VS Code Extension Exception Handling

VS Code extension methods should catch and log exceptions appropriately based on context.

- **Activation errors**: Catch, log, and re-throw to signal activation failure to VS Code.
- **Deactivation errors**: Catch and log, but do NOT re-throw - cleanup must complete.
- **Async/await errors**: Catch, log, and optionally show user-facing error message.
- **Promise chain errors**: Use `.catch()` handler with logging.

## References

- https://www.vogella.com/tutorials/EclipseLogging/article.html
- https://www.slf4j.org/codes.html#noProviders
- https://github.com/eclipse/xtext-core/issues/1363
