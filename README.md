# Sheep Dog QA

QA specifications written in AsciiDoc, used to drive test generation across the ecosystem.

## Projects

| Project | Description |
|---------|-------------|
| sheep-dog-specs | AsciiDoc specification files |

## How to Use

Run the forward engineering scripts in `sheep-dog-specs/scripts/` to generate test code from the AsciiDoc specifications.

```
scripts/forward-engineer.bat
```

This invokes the `sheep-dog-svc-maven-plugin` to transform AsciiDoc specs into Cucumber test code for the target projects.
