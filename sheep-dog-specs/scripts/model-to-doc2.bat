echo %TIME%
cd ..
call mvn clean
call mvn org.farhan:sheep-dog-dev-maven-plugin:1.1-SNAPSHOT:uml-to-asciidoctor -Dtags="%1"
cd scripts
echo %TIME%