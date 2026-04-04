# Log4j 1.2 Projects

General logging rules are found in [arch-logging.md](arch-logging.md).

## Logger Declaration

```java
import org.apache.log4j.Logger;

private static final Logger logger = Logger.getLogger(ClassName.class);
```

## Entry Logging Pattern

Log at the beginning of methods to trace execution flow.

**Simple:**
```java
logger.debug("Entering {methodName}");
```

**With Context:**
```java
logger.debug("Entering {methodName} for {contextType}: " +
    (contextObject != null ? contextObject.getName() : "null"));
```

**Examples:**
- `logger.debug("Entering checkCellNameOnly for element: " + (cell != null ? cell.getName() : "null"));`
- `logger.debug("Entering fixRowCellListWorkspace for element: " + theRow.toString());`

## Exit Logging Pattern

Log before returning from methods to trace execution completion.

**Simple:**
```java
logger.debug("Exiting {methodName}");
```

**With Result:**
```java
logger.debug("Exiting {methodName} with " + resultValue + " items");
```

## Error Logging Pattern

Log when catching exceptions to capture error context.
Include exception object as the **last parameter**.

**Simple:**
```java
logger.error("Failed in {methodName}: " + e.getMessage(), e);
```

**With Context:**
```java
logger.error("Failed in {methodName} for: " + e.getMessage(), e);
// or with element context
logger.error("Failed in {methodName} for " + element.toString() + ": " + e.getMessage(), e);
```

**Examples:**
- `logger.error("Failed in checkCellNameOnly for : "+ e.getMessage(), e);`
- `logger.error("Failed in fixRowCellListWorkspace for: " + e.getMessage(), e);`
- `logger.error("Failed in content assist for " + step.toString() + ": " + e.getMessage(), e);`

## Exception Stack Trace Pattern

**Rules:**
- ALWAYS pass the exception object as the **final parameter** to logger methods
- The logging framework automatically extracts and formats the stack trace

**Correct:**
```java
logger.error("Failed in " + methodName + ": " + e.getMessage(), e);
```

## Complete Example

```java
public static IStepDefinition generateStepDefinition(ITestStep theTestStep, ITestProject theProject) throws Exception {
    logger.debug("Entering generateStepDefinition for step: " +
        (theTestStep != null ? theTestStep.getName() : "null"));
    try {
        // Method implementation...
        logger.debug("Exiting generateStepDefinition");
        return theStepDefinition;
    } catch (Exception e) {
        logger.error("Failed in generateStepDefinition for step '" +
            (theTestStep != null ? theTestStep.getName() : "null") +
            "': " + e.getMessage(), e);
        throw e;
    }
}
```