# Xtext Logging Examples

See [impl-logging.md](sheep-dog-specs/site/impl/impl-logging.md) "Key Rules" section for pattern details.

## Overview
Custom LoggerFactory with {Language}Logger to enable SLF4J logging in Eclipse Runtime Workbench.

---

## SheepDogLoggerProvider Interface

**Path**: `sheep-dog-grammar/src/main/java/org/farhan/dsl/lang/SheepDogLoggerProvider.java`

```java
package org.farhan.dsl.lang;

import org.slf4j.Logger;

/**
 * Interface for custom logger implementations.
 * <p>
 * Separates logger provider contract from logger usage, enabling dependency
 * injection in environments without SLF4J.
 * </p>
 */
public interface SheepDogLoggerProvider {

	/**
	 * Creates a logger instance for the specified class when custom logging is
	 * needed.
	 *
	 * @param clazz the class to create a logger for
	 * @return the logger instance
	 */
	public Logger getLogger(Class<?> clazz);

}
```

---

## SheepDogLoggerFactory

**Path**: `sheep-dog-grammar/src/main/java/org/farhan/dsl/lang/SheepDogLoggerFactory.java`

```java
package org.farhan.dsl.lang;

import org.slf4j.Logger;

/**
 * Facade for logger creation that abstracts SLF4J vs custom logger providers.
 * <p>
 * Separates logging infrastructure concerns from business logic by hiding
 * provider selection and fallback.
 * </p>
 */
public class SheepDogLoggerFactory {

	/**
	 * Custom logger implementation. When set, this is used instead of SLF4J.
	 */
	private static SheepDogLoggerProvider provider = null;

	/**
	 * Configures custom logger provider for environments without SLF4J
	 * implementations (like Eclipse OSGi).
	 *
	 * @param provider the custom logger provider
	 * @throws IllegalArgumentException if provider is null
	 */
	public static void setLoggerImplementation(SheepDogLoggerProvider provider) {
		if (provider == null) {
			throw new IllegalArgumentException("Logger implementation cannot be null");
		} else {
			SheepDogLoggerFactory.provider = provider;
		}
	}

	/**
	 * Creates logger for a class by selecting SLF4J or custom provider based on
	 * availability.
	 *
	 * @param clazz the class to create a logger for
	 * @return the logger instance
	 */
	public static Logger getLogger(Class<?> clazz) {
		// Use custom impl if SLF4J has no real provider
		if (org.slf4j.LoggerFactory.getILoggerFactory() instanceof org.slf4j.helpers.NOPLoggerFactory) {
			if (provider != null) {
				return provider.getLogger(clazz);
			}
		}
		// Use SLF4J (either real provider exists, or fall back to NOP)
		return org.slf4j.LoggerFactory.getLogger(clazz);
	}

}
```

---

## {Language}RuntimeModule Configuration

**Path**: `sheepdogxtextplugin/src/org/farhan/dsl/sheepdog/SheepDogRuntimeModule.java`

```java
@Override
public void configure(Binder binder) {
	super.configure(binder);
	binder.bind(IOutputConfigurationProvider.class).to(SheepDogOutputConfigurationProvider.class)
			.in(Singleton.class);
	SheepDogFactory.instance = new SheepDogFactoryImpl(new EclipseFileRepository());
	SheepDogLoggerFactory.setLoggerImplementation(new SheepDogLogger());

	//org.apache.log4j.Logger.getRootLogger().setLevel(org.apache.log4j.Level.DEBUG);
	//org.apache.log4j.BasicConfigurator.configure();
}
```

---

## {Language}Logger

**Path**: `sheepdogxtextplugin/src/org/farhan/dsl/sheepdog/SheepDogLogger.java`

### Attributes and Constructors

```java
package org.farhan.dsl.sheepdog;

import org.apache.log4j.Level;
import org.slf4j.Logger;
import org.slf4j.Marker;
import org.farhan.dsl.lang.SheepDogLoggerProvider;

public class SheepDogLogger implements Logger, SheepDogLoggerProvider {

	private org.apache.log4j.Logger log4jLogger = null;

	public SheepDogLogger(Class<?> clazz) {
		log4jLogger = org.apache.log4j.Logger.getLogger(clazz);
	}

	public SheepDogLogger() {
		log4jLogger = null;
	}
```

### getLogger Implementation (SheepDogLoggerProvider)

```java
	@Override
	public Logger getLogger(Class<?> clazz) {
		return new SheepDogLogger(clazz);
	}
```

### format() Method - SLF4J to Log4j Placeholder Conversion

```java
	// SheepDogLogger.java
	private String format(String pattern, Object... args) {
		if (args == null || args.length == 0) {
			return pattern;
		}
		String result = pattern;
		for (Object arg : args) {
			int idx = result.indexOf("{}");
			if (idx >= 0) {
				result = result.substring(0, idx) + String.valueOf(arg) + result.substring(idx + 2);
			}
		}
		return result;
	}
```

### DEBUG Methods (Sample - Same Pattern for INFO/WARN/ERROR/TRACE)

```java
	// SheepDogLogger.java
	// ========== DEBUG ==========

	@Override
	public void debug(String msg) {
		log4jLogger.debug(msg);
	}

	@Override
	public void debug(String format, Object arg) {
		log4jLogger.debug(format(format, arg));
	}

	@Override
	public void debug(String format, Object arg1, Object arg2) {
		log4jLogger.debug(format(format, arg1, arg2));
	}

	@Override
	public void debug(String format, Object... arguments) {
		log4jLogger.debug(format(format, arguments));
	}

	@Override
	public void debug(String msg, Throwable t) {
		log4jLogger.debug(msg, t);
	}

	@Override
	public boolean isDebugEnabled() {
		return log4jLogger.isEnabledFor(Level.DEBUG);
	}

	@Override
	public boolean isDebugEnabled(Marker marker) {
		return isDebugEnabled();
	}

	@Override
	public void debug(Marker marker, String msg) {
		log4jLogger.debug(msg);
	}

	@Override
	public void debug(Marker marker, String format, Object arg) {
		log4jLogger.debug(format(format, arg));
	}

	@Override
	public void debug(Marker marker, String format, Object arg1, Object arg2) {
		log4jLogger.debug(format(format, arg1, arg2));
	}

	@Override
	public void debug(Marker marker, String format, Object... arguments) {
		log4jLogger.debug(format(format, arguments));
	}

	@Override
	public void debug(Marker marker, String msg, Throwable t) {
		log4jLogger.debug(msg, t);
	}
```

### getName Implementation

```java
	// SheepDogLogger.java
	@Override
	public String getName() {
		return log4jLogger.getName();
	}
}
```

---

## Enabling DEBUG Level

Add these lines in `SheepDogRuntimeModule.configure()`:

```java
org.apache.log4j.Logger.getRootLogger().setLevel(org.apache.log4j.Level.DEBUG);
org.apache.log4j.BasicConfigurator.configure();
```
