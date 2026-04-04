#!/bin/bash
cd "$(dirname "$0")/.."
mvn clean
mvn install -DskipTests
