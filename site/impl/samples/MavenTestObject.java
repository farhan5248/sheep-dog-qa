package org.farhan.common;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Properties;

import org.apache.maven.project.MavenProject;
import org.farhan.mbt.maven.DarmokMojo;
import org.farhan.mbt.maven.MojoLog;

/**
 * {@link TestObject} subclass that adds Maven plugin test scaffolding:
 * Mojo execution via reflection, properties-file-driven parameter defaults,
 * file I/O helpers, and dated-log inspection.
 */
public abstract class MavenTestObject extends TestObject {

    private static final Properties mojoDefaults = new Properties();

    static {
        try (InputStream is = MavenTestObject.class.getResourceAsStream("/mojo-defaults.properties")) {
            if (is != null) {
                mojoDefaults.load(is);
            }
        } catch (IOException e) {
            throw new RuntimeException("Failed to load mojo-defaults.properties", e);
        }
    }

    protected final void executeMojo(Class<? extends DarmokMojo> mojoClass) {
        Path codePrjDir = (Path) getProperty("code-prj.baseDir");
        if (codePrjDir == null) {
            throw new IllegalStateException("code-prj.baseDir not set");
        }

        try {
            DarmokMojo mojo = mojoClass.getConstructor().newInstance();

            MavenProject project = new MavenProject();
            project.setArtifactId("code-prj");
            mojo.project = project;
            mojo.setBaseDir(codePrjDir.toString());

            for (String key : mojoDefaults.stringPropertyNames()) {
                Object override = properties.get(key);
                String value = override != null ? override.toString() : mojoDefaults.getProperty(key);
                setField(mojo, key, value);
            }

            mojo.execute();
            setProperty("goal.exception", null);
        } catch (Exception e) {
            setProperty("goal.exception", e);
        }
    }

    protected final void createFile(Path path) {
        if (path == null) {
            return;
        }
        try {
            Files.createDirectories(path.getParent());
            if (!Files.exists(path)) {
                Files.writeString(path, "placeholder");
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    protected final void deleteFile(Path path) {
        if (path == null) {
            return;
        }
        try {
            Files.deleteIfExists(path);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    protected final void createOrDeleteFile(Path path) {
        String stateType = (String) getProperty("stateType");
        if ("isn't".equals(stateType)) {
            deleteFile(path);
        } else {
            createFile(path);
        }
    }

    protected final MojoLog getMojoLog(String prefix) {
        String cacheKey = "mojoLog." + prefix;
        Object cached = getProperty(cacheKey);
        if (cached instanceof MojoLog) {
            return (MojoLog) cached;
        }
        Path logDir = (Path) getProperty("log.dir");
        if (logDir == null) {
            Object baseDir = getProperty(component + ".baseDir");
            if (baseDir == null) {
                return null;
            }
            logDir = ((Path) baseDir).resolve("target").resolve("darmok");
        }
        MojoLog mojoLog = new MojoLog(MojoLog.findDatedLog(logDir, prefix));
        setProperty(cacheKey, mojoLog);
        return mojoLog;
    }

    protected final Path resolveFilePath() {
        Object baseDir = getProperty(component + ".baseDir");
        if (baseDir == null) {
            return null;
        }
        return ((Path) baseDir).resolve(object);
    }

    protected final String getFileContent(Path path) {
        String state = getFileState(path);
        return state != null ? state.replaceAll("\r", "").trim() : null;
    }

    protected final String getFileState(Path path) {
        if (path == null || !Files.exists(path)) {
            return null;
        }
        try {
            return Files.readString(path);
        } catch (IOException e) {
            return null;
        }
    }

    protected final void writeFile(Path path, String content) {
        if (path == null) {
            return;
        }
        try {
            Files.createDirectories(path.getParent());
            if (content == null) {
                content = "";
            }
            Files.writeString(path, content);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
