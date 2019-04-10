def shell(cmd) {
    return sh(script: cmd, returnStdout: true).trim()
}

def getIssues() {
    //return shell('git log --oneline ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}..${GIT_COMMIT} | cut -d " " -f 2').split('\n')
    def issues = shell('git log --oneline ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}..${GIT_COMMIT} | grep -oE "([A-Z]+-[1-9][0-9]*)"').split('\n')
    return issues.unique()
}

def getTag() {
    // return shell('git tag -l --points-at HEAD')
    // return shell('git describe --tags')
    return "11.3.67"
}

//@NonCPS
def addJiraComment(jiraIssues, releaseTag) {
    comment = [ body: "Integrated into build: ${releaseTag}" ]
    
    jiraIssues.each { issue ->
        response = jiraAddComment idOrKey: issue, input: comment
        echo response.successful.toString()
        echo response.data.toString()
    }
}

def resolveJiraIssue(jiraIssues) {
    transition = [ transition: [id: '31'] ]
    
    jiraIssues.each { issue ->
        response = jiraTransitionIssue idOrKey: issue, input: transition
        echo response.successful.toString()
        echo response.data.toString()
    }
}

def addReleaseTagToJiraIssue(jiraIssues, releaseTag) {
    modIssue = [fields: [ // id or key must present for project.
                               project: [key: 'PE'],
                               customfield_10007: ["${releaseTag}"],
                               customfield_10008: ['11.3.0.14175']
                         ]
               ]

    jiraIssues.each { issue ->
        response = jiraEditIssue idOrKey: issue, issue: modIssue
        echo response.successful.toString()
        echo response.data.toString()
    }
}

def createJiraIssue(summary, description) {
    newIssue = [fields: [ // id or key must present for project.
                               project: [key: 'PE'],
                               summary: summary,
                               description: description,
                               issuetype: [name: 'Bug'],
                               assignee: [name: 'ptt']
                         ]
               ]

    response = jiraNewIssue issue: newIssue
    echo response.successful.toString()
    echo response.data.toString()
}

def getJiraIssuesInBuild(buildNo) {
    def response = jiraJqlSearch jql: "PROJECT = PE AND customfield_10007 = ${buildNo}"
    //def reponse = jiraJqlSearch jql: 'PROJECT = PE AND type = Bug'
    echo "total: ${reponse.data.total}"
    issues = []
    reponse.data.issues.each { issue ->
        echo issue.key
        issues.add(issue.key)
    }
    echo issues
    return issues
}

def getJiraIssueReporter(issueKey) {
    def issue = jiraGetIssue idOrKey: issueKey
    echo issue.data.jiraGetReporter()
}

@NonCPS
def getChangeString(changeLogSets) {
    MAX_MSG_LEN = 100
    def changeString = ""
    for (int i = 0; i < changeLogSets.size(); i++) {
        def entries = changeLogSets[i].items
        for (int j = 0; j < entries.length; j++) {
            def entry = entries[j]
            truncated_msg = entry.msg.take(MAX_MSG_LEN)
            changeString += " - ${truncated_msg} [${entry.author}]\n"
        }
    }

    if (!changeString) {
        changeString = " - No new changes"
    }
    return changeString
}
    
pipeline {
    agent any
    
    //agent {
    //    docker { image 'maven:latest' }
    //}
    //agent { dockerfile true }
    
    //parameters {
    //    string(name: 'issues', defaultValue: 'PE-0')
    //    string(name: 'tag', defaultValue: 'release/0.0.0')
    //}
    
    stages {
        stage('pre-build') {
            steps {
                echo "Hello World!"
                echo PATH
                shell('printenv')
            }
        }
        stage('build') {
            steps {
                echo "Build"
                echo "Git branch: $GIT_BRANCH"
                echo "Commit for this build: $GIT_COMMIT"
                echo "Commit for previous successful build: $GIT_PREVIOUS_SUCCESSFUL_COMMIT"
                // sh 'mvn --version'
                script {
                    issues = getIssues()
                    echo "All Jira issues: ${issues}"
                }
                getJiraIssuesInBuild('11.3.67')
            }
        }
    }
    post {
        always {
            echo "Post actions:"
            script {
                changes = getChangeString(currentBuild.changeSets)
                echo changes
                //echo CHANGES_SINCE_LAST_SUCCESS
            }
        }
        success {
            echo "Build is successful"
            script {
                issues = getIssues()
                tag = getTag()
                echo "All Jira issues: ${issues}"
                echo "Tag: ${tag}"
                //addJiraComment(issues, tag)
                //addReleaseTagToJiraIssue(issues, tag)
                //resolveJiraIssue(issues)
            }
        }
        unstable {
            echo "Build is unstable"
        }
        failure {
            echo "Build has failed"
            //createJiraIssue("Jenkins and Jira integration for platform build: auto-created on build failure", "Jenkins build failure")
        }
        changed {
            echo "Build completion status has changed"
        }
    }
}
