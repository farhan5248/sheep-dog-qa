# SLF4J Projects

General logging rules are found in [arch-logging.md](arch-logging.md).

## Logger Declaration

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

private static final Logger logger = LoggerFactory.getLogger(ClassName.class);
```

## Entry Logging Pattern

Log at the beginning of methods to trace execution flow.

**Simple:**
```java
logger.debug("Entering {methodName}");
```

**With Context:**
```java
logger.debug("Entering {methodName} for {contextType}: {}",
    contextObject != null ? contextObject.toString() : "null");
```

**Examples:**
- `logger.debug("Entering generateStepDefinition for step: {}", theTestStep != null ? theTestStep.toString() : "null");`
- `logger.debug("Entering validateNameWorkspace");`

## Exit Logging Pattern

Log before returning from methods to trace execution completion.

**Simple:**
```java
logger.debug("Exiting {methodName}");
```

**With Result:**
```java
logger.debug("Exiting {methodName} with {resultDescription}", resultValue);
```

**Examples:**
- `logger.debug("Exiting generateStepDefinition");`
- `logger.debug("Exiting proposeName with {} proposals", proposals.size());`
- `logger.debug("Exiting getNameLong with result: {}", stepNameLong);`

## Error Logging Pattern

Log when catching exceptions to capture error context.
Include exception object as the **last parameter**.

**Simple:**
```java
logger.error("Failed in {methodName}", e);
```

**With Context:**
```java
logger.error("Failed in {methodName} for {contextType} '{}': {}",
    contextObject != null ? contextObject.toString() : "null",
    e.getMessage(), e);
```

**Examples:**
- `logger.error("Failed in generateStepDefinition for step '{}': {}", theTestStep != null ? theTestStep.toString() : "null", e.getMessage(), e);`
- `logger.error("Failed in validateCellListWorkspace", e);`

## Exception Stack Trace Pattern

**Rules:**
- ALWAYS pass the exception object as the **final parameter** to logger methods
- The logging framework automatically extracts and formats the stack trace

**Correct:**
```java
logger.error("Failed in {}: {}", methodName, e.getMessage(), e);
```

## Complete Example

```java
public static IStepDefinition generateStepDefinition(ITestStep theTestStep, ITestProject theProject) throws Exception {
    logger.debug("Entering generateStepDefinition for step: {}",
        theTestStep != null ? theTestStep.toString() : "null");
    try {
        // Method implementation...
        logger.debug("Exiting generateStepDefinition");
        return theStepDefinition;
    } catch (Exception e) {
        logger.error("Failed in generateStepDefinition for step '{}': {}",
            theTestStep != null ? theTestStep.toString() : "null",
            e.getMessage(), e);
        throw e;
    }
}
```