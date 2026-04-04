# Eclipse vs VS Code IDE Integration

This document compares how the same Xtext DSL is integrated into Eclipse (via .ui module) and VS Code (via .ide + .vscode modules).

## Content Assist Comparison

| Aspect | Eclipse (.ui) | VS Code (.ide + .vscode) |
|--------|---------------|--------------------------|
| Entry Point | `ProposalProvider.complete{Type}_{Assignment}()` | `IdeContentProposalProvider._createProposals()` |
| Proposal Type | `ConfigurableCompletionProposal` | `ContentAssistEntry` |
| Protocol | Direct Java method calls | LSP `textDocument/completion` |
| Business Logic | Delegates to sheep-dog-grammar resolvers | Same resolvers, via LSP layer |

## Quick Fix Comparison

| Aspect | Eclipse (.ui) | VS Code (.ide + .vscode) |
|--------|---------------|--------------------------|
| Annotation | `@Fix(ValidatorConstant)` | N/A (handled in service) |
| Entry Point | `QuickfixProvider.fix{Type}{Aspect}()` | `QuickFixCodeActionService.getCodeActions()` |
| Document Modification | `IModification.apply()` | `WorkspaceEdit` with `TextDocumentEdit` |
| File Creation | Eclipse `IFile` API | LSP `CreateFile` + `TextDocumentEdit` |
| Protocol | Direct Eclipse APIs | LSP `codeAction` request |

### Quick Fix Pattern (VS Code)

In VS Code, all quick fixes are handled in `{Language}QuickFixCodeActionService` rather than `{Language}IdeQuickfixProvider`.

**Why not use IdeQuickfixProvider?**

The `AbstractDeclarativeIdeQuickfixProvider` API has a limitation: the EObject is only available inside the modification lambda, not at registration time. The API signature is:

```java
acceptor.accept(label, (diagnostic, obj, document) -> {
    // EObject 'obj' is only available here, inside the lambda
    return createTextEdit(diagnostic, newText);
});
```

This means you cannot iterate through multiple proposals at registration time because you don't have access to the EObject yet. Each `accept()` call registers exactly one quickfix, and the proposals can only be computed when the modification is applied.

By using `QuickFixCodeActionService` instead, we have direct access to the document and can resolve the EObject from the diagnostic position upfront, allowing us to iterate through all proposals and create multiple CodeActions.

| Edit Type | Handling |
|-----------|----------|
| Same-file edits | `TextDocumentEdit` using `options.getURI()` and `diagnostic.getRange()` |
| Workspace edits | `CreateFile` + `TextDocumentEdit` using `p.getQualifiedName()` |

The Eclipse `.ui` module handles both in a single `QuickfixProvider` class via `IModification.apply()`, where the EObject is available via `getEObject(issue)` at proposal time.

## Code Generation Comparison

| Aspect | Eclipse (.ui) | VS Code (.ide + .vscode) |
|--------|---------------|--------------------------|
| Trigger | Automatic on file save (Xtext builder) | Manual command (`Ctrl+Shift+G`) |
| Entry Point | `{Language}Generator.doGenerate()` | `{Language}CommandService.execute()` → `{Language}Generator.generateFromResource()` |
| Generator Class | Extends `AbstractGenerator` | Extends `AbstractGenerator` (but `doGenerate()` disabled) |
| Output Config | `{Language}OutputConfigurationProvider` | N/A (writes via business logic layer) |
| Protocol | Direct Eclipse builder integration | LSP `workspace/executeCommand` |

## Syntax Highlighting Comparison

| Aspect | Eclipse (.ui) | VS Code (.vscode) |
|--------|---------------|-------------------|
| Configuration | Java `HighlightingConfiguration` class | TextMate `.tmLanguage.json` |
| Token Mapping | `AntlrTokenToAttributeIdMapper` | TextMate patterns/scopes |
| Semantic Highlighting | `SemanticHighlightingCalculator` | Embedded in TextMate patterns |
| Color Values | Java `RGB(r, g, b)` | Hex `#RRGGBB` in textMateRules |
| Context Awareness | AST-aware via EMF model | Begin/end blocks for scope isolation |

### Key Architectural Difference

**Eclipse**: Two-phase highlighting
1. Lexer phase: ANTLR tokens → style IDs via `AntlrTokenToAttributeIdMapper`
2. Semantic phase: AST traversal via `SemanticHighlightingCalculator` for sub-token coloring

**VSCode**: Single-phase pattern matching
1. TextMate regex patterns match text and assign scope names
2. Begin/end blocks create isolated scopes (e.g., `----` blocks exclude nested patterns)
3. Colors defined in `package.json` since custom scopes need explicit color mapping

## Key Differences

**Eclipse (.ui)**:
- Direct Java API calls within Eclipse runtime
- OSGi bundle with direct access to workspace
- Uses Eclipse-specific extension points

**VS Code (.ide + .vscode)**:
- Language Server Protocol (LSP) over JSON-RPC
- Separate Java process (language server) + TypeScript extension
- Platform-agnostic protocol

## Cross-References

- **Code patterns**: See [impl-xtext-eclipse.md](impl-xtext-eclipse.md) and [impl-xtext-vscode.md](impl-xtext-vscode.md)
- **Logging differences**: See [arch-xtext-logging.md](arch-xtext-logging.md) for OSGi logging constraints
