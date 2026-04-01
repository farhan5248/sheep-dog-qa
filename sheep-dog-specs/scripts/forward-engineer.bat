cd ..
call mvn clean
call mvn org.farhan:sheep-dog-svc-maven-plugin:asciidoctor-to-uml -Dtags="asciidoc-api" -Dhost="qa.sheepdog.io"
call mvn org.farhan:sheep-dog-svc-maven-plugin:asciidoctor-to-uml -Dtags="cucumber-gen" -Dhost="qa.sheepdog.io"
call mvn org.farhan:sheep-dog-svc-maven-plugin:asciidoctor-to-uml -Dtags="grammar" -Dhost="qa.sheepdog.io"
call mvn org.farhan:sheep-dog-svc-maven-plugin:asciidoctor-to-uml -Dtags="svc-maven-plugin" -Dhost="qa.sheepdog.io"
call mvn org.farhan:sheep-dog-svc-maven-plugin:asciidoctor-to-uml -Dtags="asciidoc-api-svc" -Dhost="qa.sheepdog.io"
call mvn org.farhan:sheep-dog-svc-maven-plugin:asciidoctor-to-uml -Dtags="cucumber-gen-svc" -Dhost="qa.sheepdog.io"
call mvn org.farhan:sheep-dog-svc-maven-plugin:asciidoctor-to-uml -Dtags="mcp-svc" -Dhost="qa.sheepdog.io"
cd scripts