# CLAUDE.testing.md

This file provides testing methodology guidance for Claude Code when working with the sheep-dog ecosystem.

## Testing Philosophy

The sheep-dog ecosystem is built on **Deming Driven Testing** principles, applying Toyota Production System concepts (especially Kaizen) to gradually adopt BDD (Behavior-Driven Development) and MBT (Model-Based Testing).

### Core Testing Approach

**Documentation-First Testing:**
- Specifications written in AsciiDoc using ubiquitous language
- Test cases generated from specifications via UML transformation
- Bidirectional synchronization between specs and test code

**Supported Test Frameworks:**
- **Cucumber**: BDD with Gherkin syntax
- **JUnit**: Traditional unit testing  
- **Dependency Injection**: Spring, Guice, or plain Java

## Tag-Based Test Organization

**Common Tags Across All Repositories:**
- `sheep-dog-dev`: Development-focused specifications and tests
- `sheep-dog-test`: Test automation specifications  
- `round-trip`: Round-trip engineering examples and validation

**Tag Usage in Transformations:**
```bash
# Generate tests for development context
mvn org.farhan:sheep-dog-dev-svc-maven-plugin:asciidoctor-to-uml -Dtags="sheep-dog-dev"

# Generate tests for test automation context  
mvn org.farhan:sheep-dog-dev-maven-plugin:uml-to-cucumber-guice -Dtags="sheep-dog-test"

# Generate round-trip validation tests
mvn org.farhan:sheep-dog-dev-svc-maven-plugin:asciidoctor-to-uml -Dtags="round-trip"
```

## Test Generation Patterns

### Cucumber Test Generation

**Plain Cucumber (No DI):**
```bash
mvn org.farhan:sheep-dog-dev-maven-plugin:uml-to-cucumber -Dtags="<context>"
```
- Generates basic Cucumber step definitions
- No dependency injection framework
- Suitable for simple test scenarios

**Cucumber with Spring:**
```bash
mvn org.farhan:sheep-dog-dev-maven-plugin:uml-to-cucumber-spring -Dtags="<context>"
```
- Generates Cucumber tests with Spring Boot integration
- Supports Spring's dependency injection
- Ideal for enterprise applications and microservices

**Cucumber with Guice:**
```bash
mvn org.farhan:sheep-dog-dev-maven-plugin:uml-to-cucumber-guice -Dtags="<context>"
```
- Generates Cucumber tests with Google Guice
- Lightweight dependency injection
- Good for modular, testable code

### JUnit Test Generation

**JUnit with Spring:**
```bash
mvn org.farhan:sheep-dog-dev-maven-plugin:uml-to-junit-spring -Dtags="<context>"
```
- Traditional unit tests with Spring integration
- Supports Spring Test framework features
- Good for component and integration testing

**JUnit with Guice:**
```bash
mvn org.farhan:sheep-dog-dev-maven-plugin:uml-to-junit-guice -Dtags="<context>"
```
- Unit tests with Guice dependency injection
- Lighter weight than Spring
- Suitable for focused unit testing

## Specification Writing Guidelines

### AsciiDoc Test Specifications

**Location:**
- Primary specs: `sheep-dog-qa/sheep-dog-specs/src/test/resources/asciidoc/specs/`
- Step definitions: `sheep-dog-qa/sheep-dog-specs/src/test/resources/asciidoc/stepdefs/`

**Structure:**
```asciidoc
= Test-Suite: Feature Name

@sheep-dog-test
@round-trip

== Test-Case: Scenario Name

Scenario description and context.

* Given: The application state setup
* When: The action being tested  
* Then: The expected outcome
* And: Additional verification steps
```

**Best Practices:**
- Use ubiquitous language that domain experts understand
- Write scenarios from user perspective
- Include both positive and negative test cases
- Tag appropriately for correct test generation context

### Step Definition Organization

**Application-Based Structure:**
```
stepdefs/
├── blah application/           # Application-specific steps
│   └── Object page.asciidoc   # Page object step definitions
├── daily batchjob/            # Batch job steps  
├── maven plugin/              # Plugin-specific steps
└── xtext plugin/              # IDE plugin steps
```

**Step Definition Format:**
```asciidoc
= Step-Object: Object Name

Description of the object and its purpose.

== Step-Definition: action description

Detailed description of what this step does.

* Step-Parameters: N
+
Parameter descriptions and constraints.

+
|===
| Parameter Name | Description
| value1         | What this parameter controls
|===
```

## Generated Test Code Structure

### Output Locations
```
src-gen/test/
├── java/org/farhan/
│   ├── objects/              # Page object implementations
│   │   ├── blah/            # Application-specific objects
│   │   └── maven/           # Tool-specific objects
│   └── stepdefs/            # Step definition implementations  
│       ├── blah/            # Application step implementations
│       └── maven/           # Tool step implementations
└── resources/cucumber/specs/ # Generated Cucumber feature files
```

### Generated Code Patterns

**Page Objects:**
- Generated in `src-gen/test/java/org/farhan/objects/`
- Implement common patterns for UI interaction
- Support multiple applications and contexts

**Step Definitions:**
- Generated in `src-gen/test/java/org/farhan/stepdefs/`
- Include dependency injection setup (Spring/Guice)
- Maintain parameter validation and error handling

**Feature Files:**
- Generated in `src-gen/test/resources/cucumber/specs/`
- Organized by feature area and application
- Include tags for test execution filtering

## Eclipse IDE Testing Support

### Xtext Plugin Features for Test Writing

**Content Assist:**
- Suggests applications, objects, and keywords
- Proposes parameter combinations
- Validates step syntax in real-time

**Validation:**
- Component and object validation
- Predicate validation for step completion
- Cross-reference validation between specs and step definitions

**Quick Fixes:**
- Create missing objects
- Rename objects to existing ones
- Generate missing step definitions

**Code Generation:**
- Generate step definitions from specifications
- Create page objects from step references
- Generate test runners and configuration

### Testing the IDE Plugin

**Plugin Development Testing:**
1. Run plugin in test Eclipse instance
2. Create test specifications using DSL
3. Validate content assist and quick fixes
4. Test code generation features
5. Verify generated test code compiles and runs

## Test Execution Strategies

### Local Testing

**Cucumber Tests:**
```bash
# Run all generated Cucumber tests
mvn test

# Run specific tag-filtered tests  
mvn test -Dcucumber.filter.tags="@sheep-dog-test"

# Run with specific profile
mvn test -Dspring.profiles.active=surefire
```

**Maven Surefire Integration:**
- Tests run automatically during `mvn test`
- Supports parallel execution
- Generates detailed test reports

### Cloud Testing (sheep-dog-cloud)

**Integration Testing:**
- Uses Spring Boot Test framework
- Includes contract testing with Spring Cloud Contract
- Tests REST API endpoints for transformations

**Failsafe Integration:**
- Runs integration tests in `pre-integration-test` phase
- Starts required services (database, message queue)
- Tests full service stack

### Continuous Integration Testing

**GitHub Actions Integration:**
- Automated test execution on pull requests
- Parallel test execution across repositories
- Integration with cloud deployment testing

**Test Reporting:**
- JUnit XML reports for CI integration
- Cucumber HTML reports for detailed analysis
- Contract verification reports for API testing

## Testing Best Practices

### Specification Quality

1. **Clarity**: Write specs that non-technical stakeholders can understand
2. **Completeness**: Cover happy path, edge cases, and error conditions
3. **Traceability**: Maintain clear links between specs and generated tests
4. **Maintainability**: Use consistent language and patterns

### Test Code Quality

1. **Generated Code**: Don't modify generated test code manually
2. **Custom Code**: Place custom test utilities in `src/test/` (not `src-gen/`)
3. **Dependencies**: Use appropriate DI framework for your context
4. **Isolation**: Ensure tests can run independently

### Performance Testing

1. **Tag Filtering**: Use tags to run subsets of tests during development
2. **Parallel Execution**: Configure Surefire for parallel test execution
3. **Test Data**: Use appropriate test data strategies for different contexts
4. **Resource Management**: Clean up test resources properly

### Test Debugging

**Common Issues:**
1. **Generation Failures**: Check specification syntax and tags
2. **Compilation Errors**: Verify generated code dependencies
3. **Runtime Failures**: Check DI configuration and test setup
4. **IDE Issues**: Rebuild and reinstall Xtext plugin

**Debugging Techniques:**
- Use IDE debugging for step definition development
- Check Maven test output for detailed error information
- Validate specification syntax before code generation
- Test transformations incrementally by tag