cd ..
call mvn clean
call mvn org.farhan:sheep-dog-dev-svc-maven-plugin:uml-to-asciidoctor -Dtags="%1"
cd scripts 