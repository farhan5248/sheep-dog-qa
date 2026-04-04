# Log File Implementation

General implementation details for log files across environments.

## Key Rules

1. **Always Include Method Name**: Every log message must include the method name for traceability
2. **Parameterized Logging**:
   - **SLF4J / Log4j 2.x projects**: ALWAYS use `{}` placeholders, NEVER string concatenation
   - **Log4j 1.2 projects** (e.g., Eclipse Xtext): Use string concatenation with `+` operator (parameterized logging not supported)
   - **TypeScript/VS Code projects**: Use template literals with `${}` for string interpolation
3. **Null Safety**: Check objects before accessing properties
   - Pattern: `obj != null ? obj.getName() : "null"`
4. **Context Information**: Include relevant context (step name, object name, etc.) when available
5. **Log Levels**:
   - `debug`: Entry/exit tracing, detailed flow information
   - `info`: Significant business events
   - `warn`: Recoverable issues, validation warnings
   - `error`: Exceptions, failures requiring attention

## Log File Naming Conventions

- Pattern: `{app}-{type}.log`
- Examples: `app-main.log`, `app-debug.log`, `app-trace.log`

## Log File Locations

### Local Development

| Framework | Default Location |
|-----------|------------------|
| VS Code Extensions | `~/.vscode/logs/` (Windows: `C:\Users\{username}\.vscode\logs\`) |
| Spring Boot | `./logs/` or console |
| Node.js | Console (configurable with winston/pino) |

### Cloud

| Platform | Location |
|----------|----------|
| AWS CloudWatch | `/aws/lambda/{function}`, `/ecs/{service}` |
| Azure Monitor | Log Analytics workspace |
| GCP | Cloud Logging (Stackdriver) |

## Log Rotation

- Daily rotation with compression
- Size-based rotation (e.g., 10MB per file)
- Retention period (e.g., 30 days)

## Environment Variables

| Variable | Purpose | Values |
|----------|---------|--------|
| LOG_LEVEL | Override default log level | OFF, ERROR, WARN, INFO, DEBUG, TRACE |
| LOG_PATH | Override default directory | Any valid path |

## Viewing Logs

### bash

```bash
# Search for errors
grep "ERROR" app.log

# View compressed archives
gunzip -c app-2025-01-05.log.gz | less

# Search for specific timeframe
grep "2025-01-06 14:" app.log
```

### PowerShell

```powershell
# View last 50 lines
Get-Content -Tail 50 app.log

# Search for pattern
Select-String -Path app.log -Pattern "ERROR"

# Monitor log file in real-time
Get-Content -Wait -Tail 10 app.log
```

## Log Message Format

### Standard Format

```
{timestamp} [{thread}] {level} {logger} - {message}
```

### Example

```
2025-01-06 14:30:15.123 [main] INFO o.f.app.Service - Starting service
2025-01-06 14:30:15.456 [main] ERROR o.f.app.Service - Failed to connect: Connection refused
```

### Components

| Component | Description |
|-----------|-------------|
| Timestamp | `YYYY-MM-DD HH:mm:ss.SSS` |
| Thread | Thread name in brackets |
| Level | INFO, DEBUG, WARN, ERROR, TRACE |
| Logger | Abbreviated class name |
| Message | Log message content |
