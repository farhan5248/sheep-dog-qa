cd ..
call mvn clean
call mvn org.farhan:sheep-dog-dev-svc-maven-plugin:asciidoctor-to-uml -Dtags="sheep-dog-dev"
call mvn org.farhan:sheep-dog-dev-svc-maven-plugin:asciidoctor-to-uml -Dtags="sheep-dog-test"
call mvn org.farhan:sheep-dog-dev-svc-maven-plugin:asciidoctor-to-uml -Dtags="round-trip"
cd scripts 