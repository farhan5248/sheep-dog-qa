cd ..
call mvn clean
call mvn org.farhan:sheep-dog-svc-maven-plugin:asciidoctor-to-uml -Dtags="asciidoc-api" -Dhost="dev.sheepdog.io"
call mvn org.farhan:sheep-dog-svc-maven-plugin:asciidoctor-to-uml -Dtags="cucumber-gen" -Dhost="dev.sheepdog.io"
call mvn org.farhan:sheep-dog-svc-maven-plugin:asciidoctor-to-uml -Dtags="grammar" -Dhost="dev.sheepdog.io"
call mvn org.farhan:sheep-dog-svc-maven-plugin:asciidoctor-to-uml -Dtags="svc-maven-plugin" -Dhost="dev.sheepdog.io"
cd scripts