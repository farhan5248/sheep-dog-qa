# Xtext VS Code Examples

VS Code uses the Language Server Protocol (LSP) instead of Eclipse-specific APIs. The language server runs as a separate Java process, and the VS Code extension connects to it via LSP.

## Project Initialization

VS Code cannot use the Eclipse Workspace API, so project initialization uses file system traversal to find the project root.

```java
private void initProject(Resource resource) {
	ITestProject parent = SheepDogFactory.instance.createTestProject();
	String resourcePath = resource.getURI().toFileString().replace(File.separator, "/");
	String projectPath = resourcePath.split("src/test/resources/asciidoc/specs/")[0].replace("/",
			File.separator);
	parent.setName(new File(projectPath).getAbsolutePath());
}
```

This method extracts the project root by splitting the resource path at the known spec directory location.

## Content Assist

Content assist in VS Code is handled by the LSP `textDocument/completion` request. The Xtext framework generates the LSP implementation automatically when using the IDE module.

The `{Language}IdeContentProposalProvider` extends `IdeContentProposalProvider` for LSP-compatible content assist.

```java
public class {Language}IdeContentProposalProvider extends IdeContentProposalProvider
```

Override `_createProposals` to provide custom completion proposals.

```java
@Override
protected void _createProposals(Assignment assignment, ContentAssistContext context,
		IIdeContentProposalAcceptor acceptor) {
	// Add custom proposal logic here
	super._createProposals(assignment, context, acceptor);
}
```

Use `getProposalCreator().createSnippet()` to create proposals with snippets.

```java
ContentAssistEntry proposal = getProposalCreator().createSnippet(
	replacementText, displayText, context);
if (proposal != null) {
	proposal.setDocumentation(description);
	acceptor.accept(proposal, 0);
}
```

## Quick Fix

All quick fixes are handled in `{Language}QuickFixCodeActionService` which extends `QuickFixCodeActionService`.

```java
public class {Language}QuickFixCodeActionService extends QuickFixCodeActionService {

	@Override
	public List<Either<Command, CodeAction>> getCodeActions(Options options) {
		List<Either<Command, CodeAction>> codeActions = new ArrayList<>();
		for (Diagnostic diagnostic : options.getCodeActionParams().getContext().getDiagnostics()) {
			if (canHandleDiagnostic(diagnostic)) {
				codeActions.addAll(options.getLanguageServerAccess()
						.doSyncRead(options.getURI(), (context) -> {
							options.setDocument(context.getDocument());
							options.setResource(context.getResource());
							return getCodeActionsForDiagnostic(options, diagnostic);
						}));
			}
		}
		return codeActions;
	}
}
```

Get the EObject from the diagnostic position to generate proposals.

```java
private List<Either<Command, CodeAction>> getCodeActionsForDiagnostic(Options options, Diagnostic diagnostic) {
	EObject eObject = getEObjectFromDiagnostic(options, diagnostic);
	ArrayList<SheepDogIssueProposal> proposals = {Type}IssueResolver.correct{Issue}(new {Type}Impl(eObject));
	return createCodeActions(options, diagnostic, proposals);
}
```

Create code actions for both same-file and workspace edits.

```java
private List<Either<Command, CodeAction>> createCodeActions(Options options, Diagnostic diagnostic,
		ArrayList<SheepDogIssueProposal> proposals) {
	List<Either<Command, CodeAction>> codeActions = new ArrayList<>();

	for (SheepDogIssueProposal p : proposals) {
		CodeAction action = new CodeAction();
		action.setKind(CodeActionKind.QuickFix);
		action.setTitle(p.getId());
		action.setDiagnostics(Collections.singletonList(diagnostic));

		WorkspaceEdit workspaceEdit = new WorkspaceEdit();

		if (p.getQualifiedName().isEmpty()) {
			// Same-file edit
			TextEdit textEdit = new TextEdit();
			textEdit.setRange(diagnostic.getRange());
			textEdit.setNewText(p.getValue());

			TextDocumentEdit textDocEdit = new TextDocumentEdit();
			textDocEdit.setTextDocument(new VersionedTextDocumentIdentifier(options.getURI(), null));
			textDocEdit.setEdits(List.of(textEdit));

			workspaceEdit.setDocumentChanges(List.of(Either.forLeft(textDocEdit)));
		} else {
			// Workspace edit: create new file
			CreateFile createFile = new CreateFile();
			createFile.setUri(p.getQualifiedName());
			createFile.setOptions(new CreateFileOptions());
			createFile.getOptions().setOverwrite(true);

			TextEdit textEdit = new TextEdit();
			textEdit.setRange(new Range(new Position(0, 0), new Position(0, 0)));
			textEdit.setNewText(p.getValue());

			TextDocumentEdit textDocEdit = new TextDocumentEdit();
			textDocEdit.setTextDocument(new VersionedTextDocumentIdentifier(p.getQualifiedName(), null));
			textDocEdit.setEdits(List.of(textEdit));

			workspaceEdit.setDocumentChanges(List.of(Either.forRight(createFile), Either.forLeft(textDocEdit)));
		}

		action.setEdit(workspaceEdit);
		codeActions.add(Either.forRight(action));
	}
	return codeActions;
}
```

## Code Generation

VS Code uses a command-based approach for code generation instead of automatic generation on file save.

The `{Language}CommandService` implements `IExecutableCommandService` to handle LSP commands.
Two commands are exposed — one scoped to the active file, one to the whole workspace.

```java
public class {Language}CommandService implements IExecutableCommandService {

	@Override
	public List<String> initialize() {
		return List.of("{language}.generateActive", "{language}.generateAll");
	}

	@Override
	public Object execute(ExecuteCommandParams params, ILanguageServerAccess access,
			CancelIndicator cancelIndicator) {
		if ("{language}.generateActive".equals(params.getCommand())) {
			String uri = (String) params.getArguments().get(0);
			return access.doRead(uri, (context) -> {
				return {Language}Generator.generateFromResource(context.getResource());
			}).get();
		}
		if ("{language}.generateAll".equals(params.getCommand())) {
			return access.doReadIndex((indexContext) -> {
				// Iterate all indexed resources and generate each
				return "Code generation completed for workspace";
			}).get();
		}
		return "Unknown command";
	}
}
```

The `{Language}Generator` extends `AbstractGenerator` but uses a custom entry point instead of `doGenerate`.

```java
public class {Language}Generator extends AbstractGenerator {

	@Override
	public void doGenerate(final Resource resource, final IFileSystemAccess2 fsa,
			final IGeneratorContext context) {
		// Disabled - generation triggered via command instead
	}

	public static String generateFromResource(Resource resource) {
		// Extract model and generate artifacts
		// Returns status message
	}
}
```

Register both commands in `package.json`. The active-file command is bound to the editor right-click menu and a keybinding; the all-files command is exposed only through the command palette.

```json
{
	"contributes": {
		"commands": [
			{
				"command": "{language}.server.generateActive",
				"title": "Generate Code (Active File)",
				"category": "{Language} Server"
			},
			{
				"command": "{language}.server.generateAll",
				"title": "Generate Code (All Files)",
				"category": "{Language} Server"
			}
		],
		"menus": {
			"commandPalette": [
				{ "command": "{language}.server.generateActive", "when": "false" },
				{ "command": "{language}.server.generateAll" }
			],
			"editor/context": [
				{
					"command": "{language}.server.generateActive",
					"when": "editorLangId == {language}",
					"group": "1_modification"
				}
			]
		},
		"keybindings": [{
			"command": "{language}.server.generateActive",
			"key": "ctrl+shift+alt+g",
			"mac": "cmd+shift+alt+g",
			"when": "editorLangId == {language}"
		}]
	}
}
```

Register both command handlers in `extension.ts`.

```typescript
const generateActiveCommand = vscode.commands.registerCommand(
	'{language}.server.generateActive',
	async () => {
		const activeEditor = vscode.window.activeTextEditor;
		if (!activeEditor || activeEditor.document.languageId !== '{language}') {
			vscode.window.showWarningMessage('No active {Language} document');
			return;
		}
		const documentUri = activeEditor.document.uri.toString();
		const result = await vscode.commands.executeCommand(
			'{language}.generateActive', documentUri);
		vscode.window.showInformationMessage(`Code generation result: ${result}`);
	}
);

const generateAllCommand = vscode.commands.registerCommand(
	'{language}.server.generateAll',
	async () => {
		const result = await vscode.commands.executeCommand('{language}.generateAll');
		vscode.window.showInformationMessage(`Code generation result: ${result}`);
	}
);

context.subscriptions.push(generateActiveCommand, generateAllCommand);
```

## Syntax Colouring

VS Code uses TextMate grammars (`.tmLanguage.json`) instead of Xtext's Java-based highlighting classes.

### Highlighting whole tokens

Define scopes in the TextMate grammar file.

```json
{
    "name": "SheepDog AsciiDoc",
    "scopeName": "source.asciidoc.sheepdog",
    "fileTypes": ["asciidoc"],
    "repository": {
        "comments": {
            "patterns": [{
                "name": "comment.line.number-sign.sheepdog-asciidoc",
                "begin": "^\\s*#",
                "end": "$"
            }]
        },
        "level1-keywords": {
            "patterns": [{
                "name": "markup.heading.1.sheepdog-asciidoc",
                "match": "^(=)\\s+(Step-Object:|Test-Suite:)\\s+(.+)$",
                "captures": {
                    "1": { "name": "punctuation.definition.heading.sheepdog-asciidoc" },
                    "2": { "name": "keyword.control.level1.sheepdog-asciidoc" },
                    "3": { "name": "entity.name.section.sheepdog-asciidoc" }
                }
            }]
        }
    }
}
```

### Highlighting parts of tokens

Use regex patterns with named capture groups to highlight specific parts within a match.

```json
"statement-content": {
    "patterns": [
        {
            "name": "markup.tag.sheepdog-asciidoc",
            "match": "\\b(@[a-zA-Z0-9_-]+)\\b",
            "captures": {
                "1": { "name": "entity.name.tag.sheepdog-asciidoc" }
            }
        },
        {
            "name": "markup.todo.sheepdog-asciidoc",
            "match": "\\b(TODO|FIXME|HACK|NOTE|XXX)\\b",
            "captures": {
                "1": { "name": "keyword.other.todo.sheepdog-asciidoc" }
            }
        },
        {
            "name": "markup.parameter.sheepdog-asciidoc",
            "match": "(\\{[^}\\s]+\\})",
            "captures": {
                "1": { "name": "variable.parameter.sheepdog-asciidoc" }
            }
        }
    ]
}
```

### Defining Custom Colors

Since TextMate scopes like `keyword.control.level1.sheepdog-asciidoc` are custom, VSCode themes won't recognize them. Define explicit colors in `package.json`:

```json
"configurationDefaults": {
    "editor.tokenColorCustomizations": {
        "textMateRules": [
            {
                "scope": "keyword.control.level1.sheepdog-asciidoc",
                "settings": { "foreground": "#400040", "fontStyle": "bold" }
            },
            {
                "scope": "keyword.control.level2.sheepdog-asciidoc",
                "settings": { "foreground": "#800080", "fontStyle": "bold" }
            },
            {
                "scope": "comment.line.number-sign.sheepdog-asciidoc",
                "settings": { "foreground": "#FF8000", "fontStyle": "italic" }
            },
            {
                "scope": "entity.name.tag.sheepdog-asciidoc",
                "settings": { "foreground": "#FFC90E", "fontStyle": "bold" }
            }
        ]
    }
}
```

### Eclipse to VSCode Color Mapping

| Eclipse RGB | VSCode Hex | Element |
|-------------|------------|---------|
| `RGB(64, 0, 64)` | `#400040` | Level 1 keywords |
| `RGB(128, 0, 128)` | `#800080` | Level 2 keywords |
| `RGB(128, 0, 64)` | `#800040` | Level 3 keywords |
| `RGB(255, 128, 0)` | `#FF8000` | Comments |
| `RGB(255, 201, 14)` | `#FFC90E` | Tags |
| `RGB(0, 192, 192)` | `#00C0C0` | TODO |
| `RGB(163, 73, 164)` | `#A349A4` | Tables |
| `RGB(128, 64, 0)` | `#804000` | Raw text |

### Context Isolation with Begin/End Blocks

Use begin/end patterns to prevent inner patterns from matching inside delimited blocks:

```json
"text-blocks": {
    "patterns": [{
        "name": "markup.raw.content.sheepdog-asciidoc",
        "begin": "^----$",
        "end": "^----$",
        "contentName": "string.unquoted.raw.text.sheepdog-asciidoc"
    }]
}
```

Content inside `----` blocks gets the `raw.text` scope only - tags and other patterns won't match there.
