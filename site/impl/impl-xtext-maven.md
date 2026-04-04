# Xtext Maven Examples

## Generating a new project

You can follow the tutorial steps but if you want to just start coding to play around with this, I'd just do these steps first to make sure your initial setup with dependencies etc works fine before you change anything.

1. Select **File > New > Project > Xtext > Xtext Project > Next**.
3. Fill out the form as follows and then click **Next**
*  **Location** `My git repo`
*  **Project name** `sheepdogxtextplugin`. It's whatever you want to call your Eclipse project. In the beginning this is also used as the Maven **artifactID** and **groupID**. Whatever you choose will have `parent` appended to it automatically.
*  **Name** `org.farhan.dsl.sheepdog.SheepDog`. 
*  **Extensions** `asciidoc`. is asciidoc since I want to associate those files with this editor.
4. Select **Create Update Site** and set **Preferred Build System** to `Maven`

### Update the Maven Repository groupId

In the **sheepdogxtextplugin.parent** directory, update the **groupID** from `<groupId>sheepdogxtextplugin</groupId>` to `<groupId>org.farhan</groupId>` for all the `pom.xml` files

### Update the target platform

This is only needed for Eclipse plug-ins
1. Open the **sheepdogxtextplugin.parent/sheepdogxtextplugin.target/sheepdogxtextplugin.target.target** file.
2. Select the each of the items in **Locations** and click **Update**
3. Click the **Set as Active Target Platform** in the top right corner and then click **Reload TargetPlatform**. 

### Update the workflow file

Change or add these parameters. If you generate the artifacts before updating it, you'll have to manually clean out the **.xtend** files in the various directories.

```
language = StandardLanguage {
	name = "org.farhan.dsl.sheepdog.SheepDog"
	fileExtensions = "asciidoc"
	formatter = {
		generateStub = true
	}
	serializer = {
		generateStub = false
	}
	validator = {
		generateDeprecationValidation = true
	}
	generator = {
		generateXtendStub = false
	}
	junitSupport = {
		junitVersion = "5"
		generateXtendStub = false
		skipXbaseTestingPackage = true
	}
}
```

### Generate source files

Right click the **sheepdogxtextplugin/src/org/farhan/dsl/sheepdog/SheepDog.xtext** file and select **Run As > Generate Xtext Artifacts**.

Run `mvn clean generate-sources` in the **sheepdogxtextplugin.parent** directory. 

## Building

The goal is to produce a plug-in file such as `sheepdogxtextplugin.parent\sheepdogxtextplugin.repository\target\sheepdogxtextplugin.repository-1.33.0-SNAPSHOT.zip`.
If you want to add dependencies, you don't just add them like you would in a standard Maven project, there's additional Eclipse steps. 

### Maven Repository Dependencies

Create a `lib` directory under the `sheepdogxtextplugin` directory
Add the `sheep-dog-grammar` or your dependent jar to the pom

```
<properties>
	<sheep-dog-grammar.version>1.14-SNAPSHOT</sheep-dog-grammar.version>
</properties>

<dependencies>
	<dependency>
		<groupId>org.farhan</groupId>
		<artifactId>sheep-dog-grammar</artifactId>
		<version>${sheep-dog-grammar.version}</version>
	</dependency>
</dependencies>
```

Add the `maven-dependency-plugin` to copy the jars you want into the `lib` directory.
The `stripVersion` is needed to make updating the `build.properties` simpler.

```
<plugin>
	<groupId>org.apache.maven.plugins</groupId>
	<artifactId>maven-dependency-plugin</artifactId>
	<version>3.6.1</version>
	<executions>
		<execution>
			<id>copy</id>
			<phase>initialize</phase>
			<goals>
				<goal>copy-dependencies</goal>
			</goals>
			<configuration>
				<stripVersion>true</stripVersion>
				<includeGroupIds>org.farhan</includeGroupIds>
				<outputDirectory>
					${basedir}/../${artifactId}/lib/</outputDirectory>
			</configuration>
		</execution>
	</executions>
</plugin>
```

Update the `maven-clean-plugin` to delete the jars before downloading them again. 
Even though the `copy` goal above will overwrite the jar, the `clean` phase will remove previous versions.

```
  <plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-clean-plugin</artifactId>
    <configuration>
      <filesets combine.children="append">
...
			<fileset>
				<directory>
					${basedir}/../sheepdogxtextplugin/lib/</directory>
				<includes>
					<include>**/*</include>
				</includes>
			</fileset>
...
      </filesets>
    </configuration>
  </plugin>
```

Add the `versions-maven-plugin` to update the jar version.

```
<plugin>
	<groupId>org.codehaus.mojo</groupId>
	<artifactId>versions-maven-plugin</artifactId>
	<version>2.16.2</version>
	<configuration>
		<includes>
			<include>org.farhan:*:*</include>
		</includes>
	</configuration>
</plugin>
```

Initially, copy the jar into the lib directory for the next steps:
1. In the `sheepdogxtextplugin\META-INF\MANIFEST.MF` file. 
2. In the `Runtime` tab, `Classpath` section, click on `Add` to add the jar to the list. 
3. The `MANIFEST.MF`, `build.properties` and `classpath` files should all have a reference to the jar now.
4. Rebuild the project and then you can use the jar in your code.
5. Run `mvn generate-sources` to test it out as well.

### Core Plug-in Dependencies

To referenced the jars in the plug-in during development or runtime, you have to update the MANIFEST.mf file:
1. In the `sheepdogxtextplugin\META-INF\MANIFEST.MF` file.
2. In the `Dependencies` tab, `Required Plug-ins` section, click on `Add` to add `org.eclipse.xtext.builder` to the list.

### UI Dependencies

To expose the jars included in the core plug-in, you need do this:
1. In the `sheepdogxtextplugin\META-INF\MANIFEST.MF` file.
2. In the `Runtime` tab, `Exported Packages` section, click on `Add` to add everything in the `org.farhan.*` to the list. 

## Releasing

In general, even though Xtext supports Maven integration, it's basically ignoring almost everything you do with Maven. It's almost like Maven is just used as the program to call some Eclipse specific code (Tycho I believe) through the command line perhaps. For example `mvn test` doesn't work like you'd expect. 
The Maven release process doesn't touch the `feature.xml` or `MANIFEST.MF` files. 
Eventually I had to make the `sheep-dog-mgmt-maven-plugin` in the `sheep-dog-ops` git repo to mimic what the release plugin does. 
