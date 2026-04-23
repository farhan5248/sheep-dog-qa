package org.farhan.common;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.lang.reflect.Field;
import java.util.Set;
import java.util.stream.Collectors;

import org.junit.jupiter.api.Assertions;

import io.cucumber.datatable.DataTable;

/**
 * Common base for project-specific test scaffolding.
 *
 * <p>
 * Purpose: hold shared properties and table-interpretation logic used when
 * running Cucumber-driven tests. Projects extend a bounded-context subclass
 * (MavenTestObject, EMFTestObject, RESTTestObject, MCPTestObject, ...) rather
 * than this class directly.
 *
 * <p>
 * Table-style interpretation supports two feature-file shapes:
 * <ul>
 * <li>Vertical — one value per row, single data column. Each row produces a
 * sibling child under the same parent.</li>
 * <li>Horizontal — one row with many columns. Each column fills a different
 * property within the same model element.</li>
 * </ul>
 */
public abstract class TestObject {

    public enum TestState {
        Absent, Empty, Present, Any;

        private static final Set<String> NAMES = Arrays.stream(values()).map(Enum::name).collect(Collectors.toSet());

        public static boolean contains(String value) {
            return NAMES.contains(value);
        }
    }

    public static HashMap<String, Object> properties = new HashMap<String, Object>();

    public static void reset() {
        TestObject.properties.clear();
    }

    protected static Object getProperty(String key) {
        return properties.get(key);
    }

    protected static void setProperty(String key, Object value) {
        properties.put(key, value);
    }

    protected String component;

    protected String object;

    public void assertVertexStep(String partDesc, String partType, String stateType, String stateDesc) {
        putProperties(partDesc, partType, stateType, stateDesc);
        processInputOutputsStepDefinitionRef(stateDesc, "get", partDesc, partType, stateType);
    }

    public void assertVertexStep(String partDesc, String partType, String stateType, String stateDesc,
            DataTable dataTable) {
        putProperties(partDesc, partType, stateType, stateDesc);
        processInputOutputsStepDefinitionRef(stateDesc, "get", partDesc, partType, stateType);
        processInputOutputsTable(dataTable, "get", partDesc, partType, stateType);
    }

    public void assertVertexStep(String partDesc, String partType, String stateType, String stateDesc, String text) {
        putProperties(partDesc, partType, stateType, stateDesc);
        processInputOutputsStepDefinitionRef(stateDesc, "get", partDesc, partType, stateType);
        processInputOutputsText(text, "get", partDesc, partType, stateType);
    }

    public void doEdgeStep(String partDesc, String partType, String stateType, String stateDesc) {
        putProperties(partDesc, partType, stateType, stateDesc);
        processInputOutputsStepDefinitionRef(stateDesc, "set", partDesc, partType, stateType);
    }

    public void doEdgeStep(String partDesc, String partType, String stateType, String stateDesc, DataTable dataTable) {
        putProperties(partDesc, partType, stateType, stateDesc);
        processInputOutputsTable(dataTable, "set", partDesc, partType, stateType);
        processInputOutputsStepDefinitionRef(stateDesc, "set", partDesc, partType, stateType);
    }

    public void doEdgeStep(String partDesc, String partType, String stateType, String stateDesc, String text) {
        putProperties(partDesc, partType, stateType, stateDesc);
        processInputOutputsText(text, "set", partDesc, partType, stateType);
        processInputOutputsStepDefinitionRef(stateDesc, "set", partDesc, partType, stateType);
    }

    public void setVertexStep(String partDesc, String partType, String stateType, String stateDesc) {
        putProperties(partDesc, partType, stateType, stateDesc);
        processInputOutputsStepDefinitionRef(stateDesc, "set", partDesc, partType, stateType);
    }

    public void setVertexStep(String partDesc, String partType, String stateType, String stateDesc,
            DataTable dataTable) {
        putProperties(partDesc, partType, stateType, stateDesc);
        processInputOutputsStepDefinitionRef(stateDesc, "set", partDesc, partType, stateType);
        processInputOutputsTable(dataTable, "set", partDesc, partType, stateType);
    }

    public void setVertexStep(String partDesc, String partType, String stateType, String stateDesc, String text) {
        putProperties(partDesc, partType, stateType, stateDesc);
        processInputOutputsStepDefinitionRef(stateDesc, "set", partDesc, partType, stateType);
        processInputOutputsText(text, "set", partDesc, partType, stateType);
    }

    private void putProperties(String partDesc, String partType, String stateType, String stateDesc) {
        properties.put("partDesc", partDesc);
        properties.put("partType", partType);
        properties.put("stateType", stateType);
        properties.put("stateDesc", stateDesc);
    }

    private void processInputOutputsStepDefinitionRef(String stateDesc, String operation, String partDesc,
            String partType, String stateType) {
        boolean negativeTest = false;
        if (stateType.contentEquals("isn't") || stateType.contentEquals("won't be")) {
            negativeTest = true;
        }
        String sectionName = (partDesc + " " + partType).trim();
        HashMap<String, String> row = new HashMap<String, String>();
        row.put(stateDesc, "");
        try {
            Object returnValue = this.getClass()
                    .getMethod(operation + convertToPascalCase(sectionName) + convertToPascalCase(stateDesc),
                            HashMap.class)
                    .invoke(this, row);
            if (operation.equals("get")) {
                String expectedValue = convertToPascalCase(stateDesc);
                String actual = returnValue == null ? null : returnValue.toString();
                if (TestState.contains(convertToPascalCase(stateDesc))) {
                    String mappedActual;
                    if (actual == null)
                        mappedActual = TestState.Absent.name();
                    else if (actual.isEmpty())
                        mappedActual = TestState.Empty.name();
                    else
                        mappedActual = TestState.Present.name();
                    if (negativeTest) {
                        Assertions.assertNotEquals(expectedValue, mappedActual);
                    } else {
                        Assertions.assertEquals(expectedValue, mappedActual);
                    }
                } else {
                    if (negativeTest) {
                        Assertions.assertNull(actual);
                    } else {
                        Assertions.assertNotNull(actual);
                    }
                }
            }
        } catch (Exception e) {
            Assertions.fail(e);
        }
    }

    private void processInputOutputsTable(DataTable dataTable, String operation, String partDesc, String partType,
            String stateType) {
        boolean negativeTest = false;
        if (stateType.contentEquals("isn't") || stateType.contentEquals("won't be")) {
            negativeTest = true;
        }
        String sectionName = (partDesc + " " + partType).trim();
        List<List<String>> data = dataTable.asLists();
        ArrayList<String> headers = new ArrayList<String>();
        for (String cell : data.get(0)) {
            headers.add(cell);
        }
        for (int i = 1; i < data.size(); i++) {
            HashMap<String, String> row = new HashMap<String, String>();
            for (int j = 0; j < headers.size(); j++) {
                row.put(headers.get(j), replaceKeyword(data.get(i).get(j)));
            }
            for (String fieldName : headers) {
                try {
                    Object returnValue = this.getClass()
                            .getMethod(operation + convertToPascalCase(sectionName) + convertToPascalCase(fieldName),
                                    HashMap.class)
                            .invoke(this, row);
                    if (operation.equals("get")) {
                        String expectedValue = row.get(fieldName);
                        if (TestState.Any.name().equals(expectedValue)) {
                            continue;
                        }
                        Map<String, String> actualByStore = toStoreMap(returnValue);
                        for (String actual : actualByStore.values()) {
                            if (fieldName.equals("State") && TestState.contains(expectedValue)) {
                                String mappedActual;
                                if (actual == null)
                                    mappedActual = TestState.Absent.name();
                                else if (actual.isEmpty())
                                    mappedActual = TestState.Empty.name();
                                else
                                    mappedActual = TestState.Present.name();
                                if (negativeTest) {
                                    Assertions.assertNotEquals(expectedValue, mappedActual);
                                } else {
                                    Assertions.assertEquals(expectedValue, mappedActual);
                                }
                            } else {
                                if (negativeTest) {
                                    Assertions.assertNotEquals(expectedValue, actual);
                                } else {
                                    Assertions.assertEquals(expectedValue, actual);
                                }
                            }
                        }
                    }
                } catch (Exception e) {
                    Assertions.fail(e);
                }
            }
        }
    }

    private void processInputOutputsText(String text, String operation, String partDesc, String partType,
            String stateType) {
        text = replaceKeyword(text);
        boolean negativeTest = false;
        if (stateType.contentEquals("isn't") || stateType.contentEquals("won't be")) {
            negativeTest = true;
        }
        String fieldName = "Content";
        String sectionName = (partDesc + " " + partType).trim();
        HashMap<String, String> row = new HashMap<String, String>();
        row.put(fieldName, text);
        try {
            Object returnValue = this.getClass()
                    .getMethod(operation + convertToPascalCase(sectionName) + convertToPascalCase(fieldName),
                            HashMap.class)
                    .invoke(this, row);
            if (operation.equals("get")) {
                String actual = returnValue == null ? null : returnValue.toString();
                if (negativeTest) {
                    Assertions.assertNotEquals(text, actual);
                } else {
                    Assertions.assertEquals(text, actual);
                }
            }
        } catch (Exception e) {
            Assertions.fail(e);
        }
    }

    @SuppressWarnings("unchecked")
    private static Map<String, String> toStoreMap(Object returnValue) {
        if (returnValue instanceof String key) {
            Object maybeStores = properties.get(key);
            if (maybeStores instanceof Map<?, ?>) {
                properties.remove(key);
                return (Map<String, String>) maybeStores;
            }
        }
        Map<String, String> stores = new LinkedHashMap<>();
        stores.put("default", returnValue == null ? null : returnValue.toString());
        return stores;
    }

    @SuppressWarnings("unchecked")
    protected static void setUuidProperty(String uuid, String store, String value) {
        Map<String, String> stores = (Map<String, String>) properties.get(uuid);
        if (stores == null) {
            stores = new LinkedHashMap<>();
            properties.put(uuid, stores);
        }
        stores.put(store, value);
    }

    private static String replaceKeyword(String value) {
        if (value.contentEquals(TestState.Empty.name().toLowerCase())) {
            return "";
        } else {
            return value;
        }
    }

    private static String convertToPascalCase(String s) {
        StringBuilder result = new StringBuilder();
        for (String word : s.split("[ \\-\\(\\)/]+")) {
            if (!word.isEmpty()) {
                result.append(Character.toUpperCase(word.charAt(0)));
                if (word.length() > 1) {
                    result.append(word.substring(1));
                }
            }
        }
        return result.toString();
    }

    protected String getFullNameFromPath() {
        return object.replaceFirst("^src/test/resources/[^/]+/", "");
    }

    protected String listToCsvString(List<?> list) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < list.size(); i++) {
            if (i > 0) {
                sb.append(", ");
            }
            sb.append(list.get(i).toString());
        }
        return sb.toString();
    }

    protected void setComponent(String component) {
        this.component = component;
    }

    protected void setObject(String object) {
        this.object = object;
    }

    protected static void setField(Object target, String fieldName, String value) {
        try {
            Field field = findField(target.getClass(), fieldName);
            if (field == null) {
                return;
            }
            field.setAccessible(true);
            Class<?> type = field.getType();
            if (type == String.class) {
                field.set(target, value);
            } else if (type == int.class || type == Integer.class) {
                field.set(target, Integer.parseInt(value));
            } else if (type == boolean.class || type == Boolean.class) {
                field.set(target, Boolean.parseBoolean(value));
            }
        } catch (NoSuchFieldException e) {
            // field doesn't exist on this class, skip
        } catch (Exception e) {
            throw new RuntimeException("Failed to set field " + fieldName, e);
        }
    }

    protected static Field findField(Class<?> clazz, String fieldName) throws NoSuchFieldException {
        while (clazz != null) {
            try {
                return clazz.getDeclaredField(fieldName);
            } catch (NoSuchFieldException e) {
                clazz = clazz.getSuperclass();
            }
        }
        throw new NoSuchFieldException(fieldName);
    }

}
