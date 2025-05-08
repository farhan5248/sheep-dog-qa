cd ..
call mvn clean
call mvn org.farhan:sheep-dog-dev-maven-plugin:1.26-SNAPSHOT:uml-to-asciidoctor -Dtags="%1" -DrepoDir=""
cd scripts 