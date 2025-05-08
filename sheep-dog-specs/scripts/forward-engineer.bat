cd ..
call mvn clean
call mvn org.farhan:sheep-dog-dev-maven-plugin:1.26-SNAPSHOT:asciidoctor-to-uml -Dtags="sheep-dog-dev" -DrepoDir=""
call mvn org.farhan:sheep-dog-dev-maven-plugin:1.26-SNAPSHOT:asciidoctor-to-uml -Dtags="sheep-dog-test" -DrepoDir=""
call mvn org.farhan:sheep-dog-dev-maven-plugin:1.26-SNAPSHOT:asciidoctor-to-uml -Dtags="round-trip" -DrepoDir=""
cd scripts 