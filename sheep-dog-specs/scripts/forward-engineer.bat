cd ..
call mvn clean
call mvn org.farhan:sheep-dog-dev-svc-maven-plugin:asciidoctor-to-uml -Dtags="api" -Dhost="dev.sheepdog.io"
call mvn org.farhan:sheep-dog-dev-svc-maven-plugin:asciidoctor-to-uml -Dtags="gen" -Dhost="dev.sheepdog.io"
call mvn org.farhan:sheep-dog-dev-svc-maven-plugin:asciidoctor-to-uml -Dtags="sheep-dog-grammar" -Dhost="dev.sheepdog.io"
call mvn org.farhan:sheep-dog-dev-svc-maven-plugin:asciidoctor-to-uml -Dtags="round-trip" -Dhost="dev.sheepdog.io"
cd scripts