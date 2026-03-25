cd ..
call mvn clean
call mvn org.farhan:sheep-dog-dev-svc-maven-plugin:asciidoctor-to-uml -Dtags="sheep-dog-grammar" -Dhost="dev.sheepdogdev.io"
call mvn org.farhan:sheep-dog-dev-svc-maven-plugin:asciidoctor-to-uml -Dtags="round-trip" -Dhost="dev.sheepdogdev.io"
cd scripts 