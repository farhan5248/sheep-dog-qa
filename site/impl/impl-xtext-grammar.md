# Xtext Grammar Examples

There's keywords, terminals and types. You define types using keyword, terminals and types.

1. Keywords are literal strings like `Given:`. 
2. Terminals are like literals, they're defined with regular expressions.
3. Types have assignments, keywords and terminals.

When creating your `.xtext` file you need to keep an eye on the generated Java classes.
Like I first tried having one `Step` keyword with `(Given|When|Then|And|But|*)` but then I didn't get a Java class per keyword, just one for `Step`. 
The problem with not having `(Given|When|Then|And|But|*)` is that when you create a `Step`, the API automatically picks the keyword. In this case, it'll always pick `Given` and there's no simple way to override it that I know of currently.
So I guess you have to balance that duplication in your `.xtext` file.

When naming the grammar in the `xtext` file, this line controls the generated package.

```
grammar org.farhan.dsl.sheepdog.SheepDog hidden(WS, SL_COMMENT)
```

Types can be like interfaces or abstract classes like `Model` or `TestStepContainer`.

```xtext
Model:
	StepObject | TestSuite;
	
TestStepContainer:
	TestSetup | TestCase;
```

Types can also be like classes with named assignments that make up the setters/getters like `TestSuite:`.

```xtext
TestSuite:
	'=' 'Test-Suite:' name=Title EOL
	statementList+=Statement*
	testStepContainerList+=TestStepContainer*;
```

Some assignments are optional like `(table=Table | text=Text)?;`.
The one that isn't set is null.

```java
public void format(IFormattableDocument doc, SheepDogGrammarAccess ga, SheepDogFormatter df) {
	...
	if (theTestStep.getTable() != null) {
		TableFormatter formatter = new TableFormatter(theTestStep.getTable());
		formatter.format(doc, ga, df);
	}
	if (theTestStep.getText() != null) {
		TextFormatter formatter = new TextFormatter(theTestStep.getText());
		formatter.format(doc, ga, df);
	}
}
```

Some assignments are collections like `rowList` or `cellList`. 

```xtext
Table:
	'+' EOL
	'|===' EOL
	rowList+=Row+
	'|===' EOL;

Row:
	cellList+=Cell+ EOL;

Cell:
	'|' name=Title;
```

If `*` is used for lists, then the getter returns an empty list.

```java
for (Statement s : theFeature.getStatementList()) {
	StatementFormatter formatter = new StatementFormatter(s);
	formatter.isLast(isLastElement(s, theFeature.getStatementList()));
	formatter.format(doc, ga, df);
}
```

If `+` is used for lists but the containing type is optional, then the getter returns null instead of a list.

```xtext
TestData:
	'*' 'Test-Data:' name=Title EOL
	statementList=NestedStatementList?
	table=Table;

NestedStatementList:
	'+' EOL
	statementList+=Statement+;
```

```java
if (theTestData.getStatementList() != null) {
	NestedStatementListFormatter formatter = new NestedStatementListFormatter(theTestData.getStatementList());
	formatter.format(doc, ga, df);
}
```

## Custom Lexer Override Pattern

The custom lexer extends the generated `Internal{Language}Lexer` and overrides `mTokens()` to control token recognition order.

### General Idea

1. Identify initial keyword
2. Greedily handle tokens that follow till end of line

### Token Rule Categories

**Multi-line rules** (automatic greedy collection):
- `RAWTEXT` (delimited by `----` or `"""`)
- Multiline comments (if implemented)

**Single-line rules** (5 categories based on what follows the keyword):
1. **No collection** - Token stands alone: `+`, `|===`, `*`, `==`, `=`
2. **Automatic collection** - Collects until newline: `#` (comments)
3. **No delimiter collection** - List elements with no delimiter keywords: `Test-Suite:`, `Step-Object:`, etc.
4. **Constant delimiter collection** - List elements with same delimiter: `|` (tables), `@` (tags)
5. **Variable delimiter collection** - List elements with varying delimiters: `Given:`, `When:`, `Then:`, `And:` (step keywords with expressions)

### State Flags

| Flag | Purpose |
|------|---------|
| `hasNoDelimiter` | After keywords like `Test-Suite:`, treat following tokens as WORD |
| `hasConstantDelimiter` | After `\|` or `@`, check for same delimiter or WORD |
| `hasVariableDelimiter` | After step keywords, delegate to `super.mTokens()` for expression parsing |

### Class Structure

```java
package org.farhan.dsl.{language}.parser.antlr.internal;

import org.antlr.runtime.*;
import org.apache.log4j.Logger;

@SuppressWarnings("all")
public class {Language}Lexer extends Internal{Language}Lexer {

	private static final Logger logger = Logger.getLogger({Language}Lexer.class);

	// Used to escape keywords
	private boolean hasNoDelimiter = false;
	private boolean hasConstantDelimiter = false;
	private boolean hasVariableDelimiter = false;

	public {Language}Lexer() {
	}

	public {Language}Lexer(CharStream input) {
		this(input, new RecognizerSharedState());
	}

	public {Language}Lexer(CharStream input, RecognizerSharedState state) {
		super(input, state);
	}
```

### Lookahead Pattern

The `isKeyword()` method uses `input.LA()` for character lookahead without consuming tokens:

```java
public boolean isKeyword(String s) throws MismatchedTokenException {
	int i = 0;
	while (i < s.length()) {
		input.LA(i + 1);
		if (input.LA(i + 1) != s.charAt(i)) {
			return false;
		}
		i++;
	}
	logger.debug("isKeyword >>>" + s + "<<<");
	return true;
}
```

### Debug Logging Method

The `printNextToken()` method outputs the next token for debugging:

```java
public void printNextToken() throws MismatchedTokenException {
	int i = 0;
	try {
		String s = "";
		while (!Character.isWhitespace(input.LA(i))) {
			s += Character.toString(input.LA(i));
			i++;
		}
		logger.debug("Token >>>" + s + "<<<");
	} catch (Exception e) {
		logger.debug("Error >>>" + input.LA(i) + "<<<");
	}
}
```

### mTokens Override Pattern

The `mTokens()` method is structured by token category:

```java
@Override
public void mTokens() throws RecognitionException {
	// whitespace
	if (isKeyword(" ") || isKeyword("\t") || isKeyword("\r")) {
		mRULE_WS();
	// multi line greedy automatic collection
	} else if (isKeyword("----")) {
		mRULE_RAWTEXT();
	// delimiter reset
	} else if (isKeyword("\n")) {
		mRULE_EOL();
		hasNoDelimiter = false;
		hasConstantDelimiter = false;
		hasVariableDelimiter = false;
	// handle greedy collection by delimiter
	} else if (hasNoDelimiter) {
		mRULE_WORD();
	} else if (hasConstantDelimiter) {
		if (isKeyword("|")) {
			mT__25();
		} else {
			mRULE_WORD();
		}
	} else if (hasVariableDelimiter) {
		super.mTokens();
	// single line no collection
	} else if (isKeyword("+")) {
		mT__23();
	} else if (isKeyword("|===")) {
		mT__24();
	} else if (isKeyword("*")) {
		mT__13();
	} else if (isKeyword("==")) {
		mT__11();
	} else if (isKeyword("=")) {
		mT__9();
	// single line automatic collection
	} else if (isKeyword("#")) {
		mRULE_SL_COMMENT();
	// single line no delimiter collection
	} else if (isKeyword("Step-Object:")) {
		mT__10();
		hasNoDelimiter = true;
	} else if (isKeyword("Step-Definition:")) {
		mT__12();
		hasNoDelimiter = true;
	} else if (isKeyword("Step-Parameters:")) {
		mT__14();
		hasNoDelimiter = true;
	} else if (isKeyword("Test-Suite:")) {
		mT__15();
		hasNoDelimiter = true;
	} else if (isKeyword("Test-Setup:")) {
		mT__16();
		hasNoDelimiter = true;
	} else if (isKeyword("Test-Case:")) {
		mT__17();
		hasNoDelimiter = true;
	} else if (isKeyword("Test-Data:")) {
		mT__18();
		hasNoDelimiter = true;
	// single line constant delimiter collection
	} else if (isKeyword("|")) {
		mT__25();
		hasConstantDelimiter = true;
	// single line variable delimiter collection
	} else if (isKeyword("Given:")) {
		mT__19();
		hasVariableDelimiter = true;
	} else if (isKeyword("When:")) {
		mT__20();
		hasVariableDelimiter = true;
	} else if (isKeyword("Then:")) {
		mT__21();
		hasVariableDelimiter = true;
	} else if (isKeyword("And:")) {
		mT__22();
		hasVariableDelimiter = true;
	// catch all
	} else {
		mRULE_WORD();
	}
}
```

### Lexer Variations by Project

**Eclipse/VSCode (SheepDog/AsciiDoc)** - Uses all 3 flags:
- `hasNoDelimiter` - For `Test-Suite:`, `Step-Object:`, etc.
- `hasConstantDelimiter` - For `|` (table cells)
- `hasVariableDelimiter` - For `Given:`, `When:`, `Then:`, `And:` (step keywords with expressions)
- RAWTEXT delimiter: `----`

**Cucumber** - Uses only 2 flags (no variable delimiter):
- `hasNoDelimiter` - For `Feature:`, `Scenario:`, AND step keywords (`Given`, `When`, `Then`, `And`, `But`, `*`)
- `hasConstantDelimiter` - For `|` (table cells) AND `@` (tags)
- RAWTEXT delimiter: `"""`
- Note: Cucumber step keywords use `hasNoDelimiter` because step text has no embedded keywords to parse

### Custom Parser Wrapper

The custom parser extends the generated parser and overrides `createLexer()`:

```java
package org.farhan.dsl.{language}.parser.antlr;

import org.antlr.runtime.*;

public class Custom{Language}Parser extends {Language}Parser {
	@Override
	protected TokenSource createLexer(CharStream stream) {
		return new {Language}Lexer(stream);
	}
}
