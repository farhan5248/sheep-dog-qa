# Xtext Eclipse Examples

## Project Initialization

Eclipse uses the Workspace API to resolve the project from a resource.

```java
private static void initProject(Resource resource) {
	ITestProject parent = SheepDogFactory.instance.createTestProject();
	if (parent.getName() == null) {
		IWorkspaceRoot root = ResourcesPlugin.getWorkspace().getRoot();
		IFile file = root.getFile(new Path(resource.getURI().toPlatformString(true)));
		IProject project = file.getProject();
		parent.setName(project.getLocation().toOSString());
	}
}
```

This method uses Eclipse's `ResourcesPlugin` to get the workspace root, then resolves the `IFile` and `IProject` from the resource URI.

## Content Assist

The `{Language}ProposalProvider` extends the Xtext-generated `Abstract{Language}ProposalProvider` base class.

```java
public class {Language}ProposalProvider extends Abstract{Language}ProposalProvider
```

Override `complete{Type}_{Assignment}` methods to provide custom proposals.

```java
public void complete{Type}_{Assignment}({Type} model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
	super.complete{Type}_{Assignment}(model, assignment, context, acceptor);
	// Add custom proposal logic here
}
```

Proposals are created using `createCompletionProposal` and accepted via `acceptor.accept`.

```java
ConfigurableCompletionProposal proposal = (ConfigurableCompletionProposal) createCompletionProposal(
		proposalText, displayText, null, context);
if (proposal != null) {
	proposal.setAdditionalProposalInfo(description);
	acceptor.accept(proposal);
}
```

## Quick Fix

The `{Language}QuickfixProvider` extends `DefaultQuickfixProvider` from the Xtext framework.

```java
public class {Language}QuickfixProvider extends DefaultQuickfixProvider
```

Use `@Fix` annotations referencing `{Language}Validator` constants.

```java
@Fix({Language}Validator.{TYPE}_{ASPECT}_{ISSUE})
public void fix{Type}{Aspect}{Issue}(final Issue issue, IssueResolutionAcceptor acceptor) {
	// Add fix logic here
}
```

Proposals are created using `acceptor.accept` with an `IModification` to apply the fix.

```java
acceptor.accept(issue, label, description, "icon.png", new IModification() {
	public void apply(IModificationContext context) throws BadLocationException {
		context.getXtextDocument().replace(issue.getOffset(), issue.getLength(), replacementText);
	}
});
```

## Code Generation

The `{Language}Generator` extends Xtext's `AbstractGenerator` base class.

```java
public class {Language}Generator extends AbstractGenerator
```

Override `doGenerate` to generate code when files are saved.

```java
@Override
public void doGenerate(final Resource resource, final IFileSystemAccess2 fsa,
		final IGeneratorContext context) {
	// Extract model from resource and generate artifacts
}
```

The generator is automatically invoked by the Xtext builder when `.{extension}` files are saved. This is configured via the `org.eclipse.xtext.builder.participant` extension point in `plugin.xml`.

Output directories are configured using `{Language}OutputConfigurationProvider`.

```java
public class {Language}OutputConfigurationProvider extends OutputConfigurationProvider {

	public static final String STEP_DEFS = "STEP_DEFS";

	@Override
	public Set<OutputConfiguration> getOutputConfigurations() {
		OutputConfiguration defaultOutput = new OutputConfiguration(IFileSystemAccess.DEFAULT_OUTPUT);
		defaultOutput.setDescription("Default Output");
		defaultOutput.setOutputDirectory("./src-gen");
		defaultOutput.setCanClearOutputDirectory(true);

		OutputConfiguration stepDefs = new OutputConfiguration(STEP_DEFS);
		stepDefs.setDescription("Step Definitions");
		stepDefs.setOutputDirectory("./src/test/resources/stepdefs");
		stepDefs.setCanClearOutputDirectory(false);

		return Set.of(defaultOutput, stepDefs);
	}
}
```

Register the generator in `{Language}RuntimeModule`.

```java
public Class<? extends IGenerator2> bindIGenerator2() {
	return {Language}Generator.class;
}
```

## Syntax Colouring

### Highlighting whole tokens

The `SheepDogHighlightingConfiguration` is used to define the different styles.
You identify each style with an ID.

```java
	public static final String DEFAULT_ID = "default";
	public static final String WORD_ID = "string";
	public static final String COMMENT_ID = "comment";
```

You also give them names for the `Window > Preferences` like so.

```java
	@Override
	public void configure(IHighlightingConfigurationAcceptor acceptor) {
		acceptor.acceptDefaultHighlighting(DEFAULT_ID, "Default", defaultTextStyle());
		acceptor.acceptDefaultHighlighting(WORD_ID, "String", stringTextStyle());
		acceptor.acceptDefaultHighlighting(COMMENT_ID, "Comment", commentTextStyle());
		...
	}
```

Then you define each style. Each style can re-use an existing one.

```java
	public static TextStyle defaultTextStyle() {
		TextStyle textStyle = new TextStyle();
		textStyle.setColor(new RGB(0, 0, 0));
		return textStyle;
	}

	public static TextStyle documentTextStyle() {
		TextStyle textStyle = defaultTextStyle().copy();
		textStyle.setColor(new RGB(128, 64, 0));
		return textStyle;
	}

	public static TextStyle keywordLevel1TextStyle() {
		TextStyle textStyle = defaultTextStyle().copy();
		textStyle.setColor(new RGB(64, 0, 64));
		textStyle.setStyle(SWT.BOLD);
		return textStyle;
	}
```

The `SheepDogAntlrTokenToAttributeIdMapper` maps tokens to custom ID that you create.
There are two types of tokens, terminal ones beginning with `RULE` and the keyword ones which have the keyword like `'Given:'`.
Make sure you cover all the terminals and keywords in your `.xtext` file.

```java
		switch (tokenName) {
		case "RULE_EOL":
			// nothing to do here
		case "RULE_WS":
			// nothing to do here
		case "RULE_WORD":
			return SheepDogHighlightingConfiguration.WORD_ID;
		case "RULE_SL_COMMENT":
			return SheepDogHighlightingConfiguration.COMMENT_ID;
		case "RULE_RAWTEXT":
			return SheepDogHighlightingConfiguration.DOC_ID;
		...
		default:
			return SheepDogHighlightingConfiguration.DEFAULT_ID;
		}
```

### Highlighting parts of tokens

The `SheepDogSemanticHighlightingCalculator` is for things that don't have tokens like `Test-Data` parameters in step names.
You can get creative with this, like if you see a table header doesn't have a param in the outline itself, you can highlight the header name.

```java
	private void highlightStepParameters(TestStep testStep, IHighlightedPositionAcceptor acceptor, int current) {
		if (testStep != null) {
			INode node = NodeModelUtils.getNode(testStep);
			int start = node.getText().indexOf('{', current);
			int stop = node.getText().indexOf('}', start);
			if (start > 0 && stop > 0 && node.getText().charAt(start + 1) != ' ') {
				acceptor.addPosition(node.getTotalOffset() + start, stop - start + 1,
						SheepDogHighlightingConfiguration.TBL_ID);
				this.highlightStepParameters(testStep, acceptor, stop + 1);
			}
		}
	}
```

In this example, I'm highlighting each word in a statement differently based on whether it's a tag or todo.

```java
	private void highlightStatement(Statement statement, IHighlightedPositionAcceptor acceptor, int current) {
		if (statement != null) {
			INode node = NodeModelUtils.getNode(statement);
			int offset = node.getTotalOffset();
			for (String s : node.getText().split(" ")) {
				if (StatementUtility.isTag(s)) {
					acceptor.addPosition(offset + current, s.length(), SheepDogHighlightingConfiguration.TAG_ID);
				} else if (StatementUtility.isTodo(s)) {
					acceptor.addPosition(offset + current, s.length(), SheepDogHighlightingConfiguration.TODO_ID);
				} else {
					acceptor.addPosition(offset + current, s.length(), SheepDogHighlightingConfiguration.STATEMENT_ID);
				}
				current += s.length() + 1;
			}
		}
	}
``` 