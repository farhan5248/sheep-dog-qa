# Xtext Architecture

Architectural decisions and inter-component relationships for Xtext-based DSL implementations.

For code patterns, see `impl-xtext*.md`. For class-level patterns, see `site/uml/` in each project.

## Components

| Project | Location | Build | IDE Target |
|---------|----------|-------|------------|
| **sheep-dog-grammar** | sheep-dog-core | Maven | None |
| **sheepdogxtextplugin.parent** | sheep-dog-core | Maven/Tycho | Eclipse |
| **xtextasciidocplugin.parent** | sheep-dog-ide | Gradle | VS Code |

## Topics

### Component Integration

- [Inter-Component Dependencies](arch-xtext-bridge.md#inter-component-dependencies) - Relationship between sheep-dog-grammar and Xtext plugins
- [Bridge Pattern Architecture](arch-xtext-bridge.md#bridge-pattern-architecture) - Separating domain model from Xtext/EMF framework
- [Interface-Based Domain Model](arch-xtext-bridge.md#interface-based-domain-model) - Framework-independent interfaces
- [Lazy Parent Initialization](arch-xtext-bridge.md#lazy-parent-initialization) - EMF eContainer() usage
- [Custom LoggerFactory with {Language}Logger](arch-xtext-logging.md#architecture-decision-custom-loggerfactory-with-languagelogger) - SLF4J to Log4j bridging
- [Xtext IDE Exception Handling](arch-xtext-logging.md#xtext-ide-exception-handling) - Catch and log pattern

### IDE Comparison

- [Content Assist](arch-xtext-ide.md#content-assist-comparison) - Proposal providers and completion protocols
- [Quick Fix](arch-xtext-ide.md#quick-fix-comparison) - Document modifications and file creation
- [Code Generation](arch-xtext-ide.md#code-generation-comparison) - Automatic vs command-triggered generation
- [Syntax Highlighting](arch-xtext-ide.md#syntax-highlighting-comparison) - Java classes vs TextMate grammars

### Design Decisions

- [Grammar Element Hierarchy](arch-xtext-grammar.md#grammar-element-hierarchy) - Model structure
- [Document Parsing](arch-xtext-grammar.md#custom-parser) - Overriding generated lexer and parser
- [Three-Level Validation Strategy](arch-xtext-validation.md#three-level-validation-strategy) - FAST, NORMAL, EXPENSIVE check types
- [Dual-Purpose Issue Classes](arch-xtext-validation.md#dual-purpose-issue-classes) - Validation and content assist reuse
- [Component-Based Code Organization](arch-xtext-validation.md#component-based-code-organization) - Grouping by grammar element
