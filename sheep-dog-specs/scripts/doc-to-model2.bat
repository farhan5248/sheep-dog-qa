echo %TIME%
cd ..
call mvn clean
call mvn org.farhan:sheep-dog-dev-maven-plugin:1.1-SNAPSHOT:asciidoctor-to-uml -Dtags="%1"
cd scripts
echo %TIME%