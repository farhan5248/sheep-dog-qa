# Xtext Formatting Examples

## Navigating the AST

You can use the getters but that won't work for keywords or terminals.
Starting from the first rule, `TestSuite` in my case, follow these steps.

1. If it's a keyword, grammar access it, get region
   ```java
   formatKeywordTrailingSpace(df.getRegion(theFeature, a.getEqualsSignKeyword_0()), doc);
   ```
1. If it's a call rule, aka terminal or type
   1. If it's a terminal, grammar access it, get region
      ```java
      formatEOL2RuleCall(df.getRegion(theFeature, a.getEOLTerminalRuleCall_3()), doc);
      ```
   1. If it's a type, it's either all terminals (String) or not
      1. If it's all terminals, like Title, grammar access it, get region
         ```java
         formatTitle(df.getRegion(theFeature, a.getNameTitleParserRuleCall_2_0()), doc);
         ```
      1. If it's not all terminals
         1. If it's a collection, go through its children
            1. If it's a list of concrete elements it's easy
            ```java
            for (Statement s : theFeature.getStatementList()) {
              StatementFormatter formatter = new StatementFormatter(s);
              formatter.isLast(isLastElement(s, theFeature.getStatementList()));
              formatter.format(doc, ga, df);
            }
            ```
            1. Else if it's an abstract list, make a Factory to find the right constructor
               ```java
               for (TestStepContainer s : theFeature.getTestStepContainerList()) {
                 TestStepContainerFormatter formatter = newAbstractTestCaseFormatter(s);
                 formatter.format(doc, ga, df);
               }

               private TestStepContainerFormatter newAbstractTestCaseFormatter(TestStepContainer s) {
                 if (s instanceof TestSetup) {
                   return new TestSetupFormatter((TestSetup) s);
                 } else {
                   return new TestCaseFormatter((TestCase) s);
                 }
               }
               ```
         3. Else it's just another type so start from the top again.

## Regions

All 3 approaches below reference the same region, which can be tested by triggering a `ConflictingFormattingException`.
I stick with the `ruleCall` for terminals and types and `keyword` for keyword strings.

```java
public ISemanticRegion getRegion(EObject eo, Keyword keyword) {
	return regionFor(eo).keyword(keyword);
}

public ISemanticRegion getRegion(EObject eo, Assignment assignment) {
	return regionFor(eo).assignment(assignment);
}

public ISemanticRegion getRegion(EObject eo, RuleCall ruleCall) {
	return regionFor(eo).ruleCall(ruleCall);
}
```

### Hidden Regions

This is for stuff you define as hidden like `hidden(WS, SL_COMMENT)`.
If you don't specify formatting for each element a default kicks in.
This is more noticeable when creating a file programmatically like when the UML model is transformed into a feature file.
Anyways, what I basically do is strip out all the whitespace using the provided methods and then just tack on whitespace to the token themselves.

```java
protected void formatKeywordTrailingSpace(ISemanticRegion iSR, IFormattableDocument doc) {
	doc.prepend(iSR, it -> it.noSpace());
	doc.append(iSR, it -> it.noSpace());
	replace(doc, iSR, getIndent() + iSR.getText() + " ");
}

protected void formatEOL2RuleCall(ISemanticRegion iSR, IFormattableDocument doc) {
	doc.prepend(iSR, it -> it.noSpace());
	doc.append(iSR, it -> it.noSpace());
	replace(doc, iSR, "\n\n");
}
```

Sometimes, the whitespace isn't where you expect it.
Like it can be in the hidden region or it can be part of the token.
I experienced this with the `Text` type I created.
The differences also occur when editing the file via the GUI vs the API (through Maven).

### Text Regions

In my `.xtext` file, `EOL` are treated as statement terminators like `;` in Java so they weren't included as a hidden element.
If you want to format the white space around the non-hidden stuff like number of `EOL` in my case or aligning `Given` and `And` then you'd work directly with the text.

You'll need a class like this

```java
@SuppressWarnings("restriction")
public class TextReplacer extends AbstractTextReplacer {

  private String replacement;

  protected TextReplacer(IFormattableDocument document, ITextSegment region, String replacement) {
    super(document, region);
    this.replacement = replacement;
  }

  @Override
  public ITextReplacerContext createReplacements(ITextReplacerContext context) {
    context.addReplacement(getRegion().replaceWith(replacement));
    return context;
  }
}
```

Then invoke it like so.

```java
protected void replace(IFormattableDocument doc, ISemanticRegion iSR, String replacement) {
  doc.addReplacer(new TextReplacer(doc, iSR, replacement));
}
```