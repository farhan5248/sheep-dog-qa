cd ..
call mvn clean
call mvn org.farhan:sheep-dog-dev-maven-plugin:1.26-SNAPSHOT:asciidoctor-to-uml -DrepoDir="" -Dtags="sheep-dog-dev"
call mvn org.farhan:sheep-dog-dev-maven-plugin:1.26-SNAPSHOT:asciidoctor-to-uml -DrepoDir="" -Dtags="sheep-dog-test"
call mvn org.farhan:sheep-dog-dev-maven-plugin:1.26-SNAPSHOT:asciidoctor-to-uml -DrepoDir="" -Dtags="round-trip"
cd scripts 