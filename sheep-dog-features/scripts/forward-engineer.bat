@echo off
echo %time%

set HOST=%1
if "%HOST%"=="" (
    echo Usage: forward-engineer.bat [host]
    echo Example: forward-engineer.bat qa.sheepdog.io
    exit /b 1
)

cd ..
call mvn clean
call mvn org.farhan:sheep-dog-svc-maven-plugin:asciidoctor-to-uml -Dtags="asciidoc-api" -Dhost="%HOST%"
call mvn org.farhan:sheep-dog-svc-maven-plugin:asciidoctor-to-uml -Dtags="cucumber-gen" -Dhost="%HOST%"
call mvn org.farhan:sheep-dog-svc-maven-plugin:asciidoctor-to-uml -Dtags="grammar" -Dhost="%HOST%"
call mvn org.farhan:sheep-dog-svc-maven-plugin:asciidoctor-to-uml -Dtags="svc-maven-plugin" -Dhost="%HOST%"
call mvn org.farhan:sheep-dog-svc-maven-plugin:asciidoctor-to-uml -Dtags="asciidoc-api-svc" -Dhost="%HOST%"
call mvn org.farhan:sheep-dog-svc-maven-plugin:asciidoctor-to-uml -Dtags="cucumber-gen-svc" -Dhost="%HOST%"
call mvn org.farhan:sheep-dog-svc-maven-plugin:asciidoctor-to-uml -Dtags="mcp-svc" -Dhost="%HOST%"
cd scripts

echo %time%
