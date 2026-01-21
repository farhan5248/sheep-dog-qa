cd ..
call mvn clean
call mvn org.farhan:sheep-dog-dev-maven-plugin:1.32:uml-to-asciidoctor -Dtags="%1"
cd scripts 