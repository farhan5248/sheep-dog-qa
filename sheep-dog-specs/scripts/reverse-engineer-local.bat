cd ..
call mvn org.farhan:sheep-dog-dev-maven-plugin:1.39:uml-to-asciidoctor -DrepoDir="../../sheep-dog-qa/sheep-dog-specs/" -Dtags="%1"
cd scripts 