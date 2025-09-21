cd ..
call mvn clean
call mvn org.farhan:sheep-dog-dev-maven-plugin:1.30:asciidoctor-to-uml -DrepoDir="../../sheep-dog-qa/sheep-dog-specs/" -Dtags="sheep-dog-dev"
call mvn org.farhan:sheep-dog-dev-maven-plugin:1.30:asciidoctor-to-uml -DrepoDir="../../sheep-dog-qa/sheep-dog-specs/" -Dtags="sheep-dog-test"
call mvn org.farhan:sheep-dog-dev-maven-plugin:1.30:asciidoctor-to-uml -DrepoDir="../../sheep-dog-qa/sheep-dog-specs/" -Dtags="round-trip"
cd scripts 