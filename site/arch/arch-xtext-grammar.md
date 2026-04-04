# Grammar Structure & Parsing

## Grammar Element Hierarchy

```
Model
├── StepObject
│   ├── Statement[]
│   └── StepDefinition[]
│       ├── Statement[]
│       └── StepParameters[]
└── TestSuite
    ├── Statement[]
    └── TestStepContainer[] (TestSetup | TestCase)
        ├── Statement[]
        ├── TestStep[] (Given | When | Then | And)
        └── TestData[] (TestCase only)
```

## Custom Parser Architecture

Xtext generates keyword-first lexers that don't handle context-sensitive tokenization well. A custom lexer (`{Language}Lexer`) overrides the generated one (`Internal{Language}Lexer`) to handle:

1. **Raw text handling**: `----` or `"""` delimiters require special lookahead before regular token rules apply
2. **Keyword escaping**: Keywords appearing in table cells or step text need context-aware handling

If the grammar was defined differently with better token disambiguation, the custom lexer might not be needed. The current approach uses a state machine with delimiter flags to manage context.

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

The custom lexer uses boolean flags to track parsing context:

| Flag | Purpose |
|------|---------|
| `hasNoDelimiter` | After keywords like `Test-Suite:`, treat following tokens as WORD |
| `hasConstantDelimiter` | After `\|` or `@`, check for same delimiter or WORD |
| `hasVariableDelimiter` | After step keywords, delegate to `super.mTokens()` for expression parsing |

All flags reset to `false` on newline (`\n`), ensuring each line starts fresh.

### Lexer Variations

**Eclipse/VSCode (SheepDog/AsciiDoc)** - Uses all 3 flags:
- Step keywords use `hasVariableDelimiter` because step text can contain embedded keywords

**Cucumber** - Uses only 2 flags (no variable delimiter):
- Step keywords use `hasNoDelimiter` because Cucumber step text is plain text

### Token Priority Order

The custom `mTokens()` method checks tokens in this priority order:

1. Whitespace (` `, `\t`, `\r`)
2. Multi-line raw text (`----` or `"""`)
3. End of line (`\n`) - resets all delimiter flags
4. Greedy collection handlers (based on active delimiter flag)
5. Single-line no collection tokens (`+`, `|===`, `*`, `==`, `=`)
6. Single-line automatic collection (`#` comments)
7. Single-line no delimiter keywords (Test-Suite:, Step-Object:, etc.)
8. Single-line constant delimiter (`|`, `@`)
9. Single-line variable delimiter (Given:, When:, Then:, And:)
10. WORD token - fallback for unrecognized tokens

