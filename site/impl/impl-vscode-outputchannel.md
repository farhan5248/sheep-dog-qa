# VS Code OutputChannel Projects

General logging rules are found in [arch-logging.md](arch-logging.md).

VS Code extensions use the built-in OutputChannel API for logging. Use OutputChannel exclusively (no console.log).

## Log Format

All log entries follow the standard format from [impl-logging.md](impl-logging.md):

```
{timestamp} [{thread}] {level} {logger} - {message}
```

For VS Code extensions:
- **thread**: Use `main` (single-threaded JavaScript)
- **logger**: Use `{pluginFolder}.{moduleName}` (e.g., `xtextasciidocplugin.ServerLauncher`)

**Example output:**
```
2025-01-06 14:30:15.123 [main] DEBUG xtextasciidocplugin.extension - Entering activate
2025-01-06 14:30:15.456 [main] ERROR xtextasciidocplugin.ServerLauncher - Failed in startServer: Connection refused
```

## Logger Helper Pattern

Use the `{Language}Logger` helper module (e.g., `asciiDocLogger.ts`) for consistent log formatting.

### Logger Declaration

```typescript
import { createLogger, Logger } from './{language}Logger';

private logger: Logger;

// In constructor:
this.logger = createLogger(outputChannel, 'ModuleName');
```

### Logger Interface

```typescript
export interface Logger {
    debug: (message: string) => void;
    info: (message: string) => void;
    warn: (message: string) => void;
    error: (message: string) => void;
}
```

### createLogger Factory Function

```typescript
const PLUGIN_NAME = 'xtextasciidocplugin'; // or 'sheepdogxtextplugin'

function formatTimestamp(): string {
    const now = new Date();
    const pad = (n: number, len: number = 2) => n.toString().padStart(len, '0');
    return `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())} ` +
           `${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}.${pad(now.getMilliseconds(), 3)}`;
}

export function createLogger(outputChannel: vscode.OutputChannel, moduleName: string): Logger {
    const logger = `${PLUGIN_NAME}.${moduleName}`;
    return {
        debug: (message: string) => {
            outputChannel.appendLine(`${formatTimestamp()} [main] DEBUG ${logger} - ${message}`);
        },
        info: (message: string) => {
            outputChannel.appendLine(`${formatTimestamp()} [main] INFO ${logger} - ${message}`);
        },
        warn: (message: string) => {
            outputChannel.appendLine(`${formatTimestamp()} [main] WARN ${logger} - ${message}`);
        },
        error: (message: string) => {
            outputChannel.appendLine(`${formatTimestamp()} [main] ERROR ${logger} - ${message}`);
        }
    };
}
```

## Entry Logging Pattern

Log at the beginning of methods to trace execution flow.

**Simple:**
```typescript
logger.debug(`Entering {methodName}`);
```

**With Context:**
```typescript
logger.debug(`Entering {methodName} for {contextType}: ${contextValue}`);
```

**Examples:**
- `logger.debug(\`Entering startServer for timeout: ${configuration.timeout}\`);`
- `logger.debug(\`Entering setupConnection for client: ${client.name}\`);`

## Exit Logging Pattern

Log before returning from methods to trace execution completion.

**Simple:**
```typescript
logger.debug(`Exiting {methodName}`);
```

**With Result:**
```typescript
logger.debug(`Exiting {methodName} with ${resultDescription}`);
```

**Examples:**
- `logger.debug(\`Exiting startServer\`);`
- `logger.debug(\`Exiting getConfiguration with ${Object.keys(config).length} settings\`);`

## Error Logging Pattern

Log when catching exceptions to capture error context. Use `logger.error()` for Failed messages.

**Simple:**
```typescript
const errorMessage = error instanceof Error ? error.message : 'Unknown error';
logger.error(`Failed in {methodName}: ${errorMessage}`);
```

**With Context:**
```typescript
logger.error(`Failed in {methodName} for ${contextValue}: ${errorMessage}`);
```

**Examples:**
- `logger.error(\`Failed in startServer: ${errorMessage}\`);`
- `logger.error(\`Failed in setupConnection for client ${client.name}: ${errorMessage}\`);`

## Activation errors

**Example**
```typescript
export async function activate(context: vscode.ExtensionContext): Promise<void> {
    logger.debug('Entering activate');
    try {
        // ... activation logic
        logger.debug('Exiting activate');
    } catch (error) {
        const errorMessage = error instanceof Error ? error.message : 'Unknown error';
        logger.error(`Failed in activate: ${errorMessage}`);
        throw error; // Re-throw to signal activation failure to VS Code
    }
}
```

## Deactivation errors

**Example**
```typescript
export async function deactivate(): Promise<void> {
    logger?.debug('Entering deactivate');
    try {
        await client?.stop();
        logger?.debug('Exiting deactivate');
    } catch (error) {
        const errorMessage = error instanceof Error ? error.message : 'Unknown error';
        logger?.error(`Failed in deactivate: ${errorMessage}`);
        // Do NOT re-throw - deactivation must complete
    }
}
```

## Async/await errors

**Example**
```typescript
async function startServer(): Promise<void> {
    this.logger.debug('Entering startServer');
    try {
        await client.start();
        this.logger.debug('Exiting startServer');
    } catch (error) {
        const errorMessage = error instanceof Error ? error.message : 'Unknown error';
        this.logger.error(`Failed in startServer: ${errorMessage}`);
        vscode.window.showErrorMessage('Failed to start AsciiDoc language server');
    }
}
```

## Promise chain errors

**Example**
```typescript
client.sendRequest('custom/command', params)
    .then(result => {
        logger.debug(`Exiting sendRequest with result`);
    })
    .catch(error => {
        const errorMessage = error instanceof Error ? error.message : 'Unknown error';
        logger.error(`Failed in sendRequest: ${errorMessage}`);
    });
```

## Complete Example

```typescript
import { createLogger, Logger } from './asciiDocLogger';

class ServerLauncher {
    private logger: Logger;

    constructor(outputChannel: vscode.OutputChannel) {
        this.logger = createLogger(outputChannel, 'ServerLauncher');
    }

    async startServer(configuration: Configuration): Promise<void> {
        this.logger.debug(`Entering startServer for port: ${configuration.port}`);
        try {
            // Method implementation...
            this.logger.debug(`Exiting startServer`);
        } catch (error) {
            const errorMessage = error instanceof Error ? error.message : 'Unknown error';
            this.logger.error(`Failed in startServer: ${errorMessage}`);
            throw error;
        }
    }
}
```

**Output:**
```
2025-01-06 14:30:15.123 [main] DEBUG xtextasciidocplugin.ServerLauncher - Entering startServer for port: 8080
2025-01-06 14:30:15.456 [main] DEBUG xtextasciidocplugin.ServerLauncher - Exiting startServer
```
