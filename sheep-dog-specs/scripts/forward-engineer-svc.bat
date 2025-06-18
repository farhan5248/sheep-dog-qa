cd ..
call mvn clean
call mvn org.farhan:sheep-dog-dev-svc-maven-plugin:1.29-SNAPSHOT:asciidoctor-to-uml -Dtags="sheep-dog-dev"
call mvn org.farhan:sheep-dog-dev-svc-maven-plugin:1.29-SNAPSHOT:asciidoctor-to-uml -Dtags="sheep-dog-test"
call mvn org.farhan:sheep-dog-dev-svc-maven-plugin:1.29-SNAPSHOT:asciidoctor-to-uml -Dtags="round-trip"
call mvn org.farhan:sheep-dog-dev-svc-maven-plugin:1.29-SNAPSHOT:uml-to-cucumber-guice -Dtags="round-trip"
cd scripts 