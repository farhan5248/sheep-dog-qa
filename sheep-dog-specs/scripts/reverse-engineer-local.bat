cd ..
call mvn org.farhan:sheep-dog-dev-maven-plugin:1.46:uml-to-asciidoctor -DrepoDir="../../sheep-dog-qa/sheep-dog-specs/" -Dtags="%1"
cd scripts 