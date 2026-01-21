cd ..
call mvn clean
call mvn org.farhan:sheep-dog-dev-svc-maven-plugin:asciidoctor-to-uml -Dtags="sheep-dog-dev" -Dhost="dev.sheepdogdev.io"
call mvn org.farhan:sheep-dog-dev-svc-maven-plugin:asciidoctor-to-uml -Dtags="sheep-dog-test" -Dhost="dev.sheepdogdev.io"
call mvn org.farhan:sheep-dog-dev-svc-maven-plugin:asciidoctor-to-uml -Dtags="round-trip" -Dhost="dev.sheepdogdev.io"
cd scripts 