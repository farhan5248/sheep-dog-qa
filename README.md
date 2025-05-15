# Building and Running

These are basic steps to build the plug-ins and then test them out

1. Install Eclipse
2. Clone this repo and the qa one
3. For each project, do **Run As > Maven install**. The order shouldn't matter since all the dependencies are available online. You can find the order in the GitHub workflow files.
4. Test the Maven plug-in by running the `/home/developer/git/sheep-dog-qa/sheep-dog-specs/scripts/forward-engineer.bat` script and then `/home/developer/git/sheep-dog-local/sheep-dog-test/scripts/forward-engineer.bat` script.
5. Test the Xtext plug-in by installing the plugin archive file found in `/home/developer/git/sheep-dog-local/sheepdogxtextplugin.parent/sheepdogxtextplugin.repository/target` and modifying the files in the **sheep-dog-specs** directory.

There's 3 types of GitHub Actions workflows.
1. Those that run the Maven release plug-in on the `main` branch. They're named after each Maven module. I run these to tag Maven modules. 
2. Those that run `mvn clean deploy` on the `develop` branch. They're named after the Git repo.
3. Re-usable workflows found in the sheep-dog-ops Git repo. 
