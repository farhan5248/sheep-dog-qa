# Xtext Gradle Examples

## Generating a new project

## Building

The goal is to produce a VS Code extension file such as `xtextasciidocplugin.vscode/build/vscode/xtextasciidocplugin.vscode-1.0.0.vsix`.

### Dependency Version Management

Define version properties in the root `build.gradle` for centralized management.

```groovy
configure(subprojects.findAll { it.name.startsWith('xtextasciidocplugin') && !it.name.contains('.vscode') }) {
	ext.xtextVersion = '2.40.0'
	ext.sheepDogTestVersion = '1.24'
	ext.slf4jVersion = '2.0.16'
	ext.logbackVersion = '1.5.12'
}
```

### Maven Repository Dependencies

Configure repositories including GitHub Packages for custom dependencies.

```groovy
repositories {
	mavenCentral()
	maven {
		url = "https://maven.pkg.github.com/farhan5248/sheep-dog-core"
		credentials {
			username = project.findProperty("gpr.user") ?: 'farhan5248'
			password = project.findProperty("gpr.key") ?: System.getenv("GITHUB_TOKEN")
		}
	}
	maven {
		url = "https://repo.eclipse.org/content/groups/releases/"
	}
}
```

Add dependencies using the Xtext BOM for version alignment.

```groovy
dependencies {
	api platform("org.eclipse.xtext:xtext-dev-bom:${xtextVersion}")
	api "org.eclipse.xtext:org.eclipse.xtext:${xtextVersion}"
	api "org.farhan:sheep-dog-grammar:${sheepDogTestVersion}"
}
```

### VS Code Extension Packaging

The VS Code extension uses the Node.js plugin for npm and vsce packaging.

```groovy
apply plugin: 'com.github.node-gradle.node'
node {
	version = '20.18.2'
	npmVersion = '10.8.2'
	download = true
}

task packageExtension(dependsOn: [npmInstall]) {
	ext.destDir = new File(buildDir, 'vscode')
	ext.archiveName = "$project.name-${rootProject.version}.vsix"
	ext.destPath = "$destDir/$archiveName"
	outputs.dir destDir
	doLast {
		exec {
			workingDir = projectDir
			commandLine 'node_modules/.bin/vsce', 'package', '--out', destPath
		}
	}
}
```

## Releasing

The gradle-release plugin handles version management and tagging.

```groovy
apply plugin: 'net.researchgate.release'

release {
    tagTemplate = 'v${version}'
	preTagCommitMessage = '[release] pre tag commit: '
    tagCommitMessage = '[release] creating tag: '
    newVersionCommitMessage = '[release] new version commit: '
    failOnSnapshotDependencies = false
}
```

The `updateVersion` task syncs the VS Code package.json version with the project version.

```groovy
updateVersion {
	doLast {
		def versionPattern = /\d+.\d+(.\d+)?/
		def encoding = 'UTF-8'
		def filesToUpdate = [
			new File('xtextasciidocplugin.vscode', 'package.json'),
		]

		filesToUpdate.forEach { file ->
			if (file.exists()) {
				String text = file.getText(encoding)
				text = text.replaceAll("\"version\": \"$versionPattern\",", "\"version\": \"$project.version\",")
				file.setText(text, encoding)
			}
		}
	}
}
```

Publishing to GitHub Packages is configured per subproject.

```groovy
publishing {
	publications {
		maven(MavenPublication) {
			from components.java
			groupId = 'org.farhan'
			artifactId = project.name
			version = project.version
		}
	}
	repositories {
		maven {
			name = "GitHub"
			url = uri("https://maven.pkg.github.com/farhan5248/sheep-dog-core")
			credentials {
				username = project.findProperty("gpr.user") ?: 'farhan5248'
				password = project.findProperty("gpr.key") ?: System.getenv("GITHUB_TOKEN")
			}
		}
	}
}
```