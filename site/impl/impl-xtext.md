# Xtext Examples

The purpose of these examples is to show how to implement functionality using Xtext.
They should be read before researching on the internet.
Some files have no examples currently which is OK.

There are two types of files, core plugin files and plug-in specific.
The plug-in specific files differentiate between UI implementations
1. Eclipse UI with Maven: `git\sheep-dog-main\sheep-dog-core\sheepdogxtextplugin.parent`.
2. No UI with Maven: `git\sheep-dog-main\sheep-dog-core\sheepdogcucumber.parent`
3. VS Code UI with Gradle: `git\sheep-dog-main\sheep-dog-ide\xtextasciidocplugin.parent`

## Domain Terminology

The Xtext grammar is defined in a `.xtext` file (e.g., `SheepDog.xtext`). These variables are used in UML pattern files:

1. **{Language}** - The name of the `.xtext` file (e.g., SheepDog)
   - Example: SheepDogValidator, SheepDogBuilder, SheepDogFactory

2. **{Type}** - Non-terminal grammar rules in the `.xtext` file
   - Examples: StepObject, StepDefinition, Model, Given, Cell, Row
   - Used in: check{Type}(), fix{Type}(), I{Type}, {Type}Utility, {Type}IssueTypes

3. **{Assignment}** - Named assignments within a {Type} in the grammar
   - Examples: name, statementList, stepDefinitionList, cellList
   - Used in: complete{Type}_{Assignment}() methods, getter patterns

4. **{Aspect}** - Validation aspects not directly in grammar, derived from test specifications
   - Examples: Name, Reference, CellList
   - Used in: validate{Aspect}(), correct{Aspect}(), suggest{Aspect}()

5. **{Issue}** - Issue scope levels from {Type}IssueTypes
   - **ONLY**: Element-level validation (capitalization, regex, format)
   - **FILE**: File-level validation (first element requirements, file structure)
   - **WORKSPACE**: Cross-file validation (references to other files)

6. **{CheckType}** - Xtext validation timing/performance levels
   - **FAST**: Runs on every keystroke (CheckType.FAST) - use for element validation
   - **NORMAL**: Runs on file save (CheckType.NORMAL) - use for file validation
   - **EXPENSIVE**: Runs on demand/build (CheckType.EXPENSIVE) - use for workspace validation

7. **{IDE}** - The IDE platform for file repository implementations
   - Examples: Eclipse, VsCode
   - Used in: {IDE}FileRepository

## Core

- [Xtext Grammar Examples](impl-xtext-grammar.md)
- [Xtext Formatting Examples](impl-xtext-format.md)
- [Xtext Logging Examples](impl-xtext-logging.md)

## UI

For UI projects, the code changes in Eclipse `sheepdogxtextplugin.ui` 
correspond to the VS Code `xtextasciidocplugin.ide` and `xtextasciidocplugin.vscode`.
I will rename `.vscode` to `.ui` for consistency in the future.

- [Xtext Eclipse Examples](impl-xtext-eclipse.md)
- [Xtext VS Code Examples](impl-xtext-vscode.md)
- [Xtext Library Examples](impl-xtext-library.md)

## Build

- [Xtext Maven Examples](impl-xtext-maven.md)
- [Xtext Gradle Examples](impl-xtext-gradle.md)

