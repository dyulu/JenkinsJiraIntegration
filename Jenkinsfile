def shell(cmd) {
    return sh(script: "${cmd} || true", returnStdout: true).trim()
}

def getJiraIssuesFromCommits() {
    if (GIT_PREVIOUS_SUCCESSFUL_COMMIT == GIT_COMMIT)
        return null
    
    //return shell('git log --oneline ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}..${GIT_COMMIT} | cut -d " " -f 2').split('\n')
    def issues = shell('git log --oneline ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}..${GIT_COMMIT} | \
                        grep -oE "([a-zA-Z]+-[1-9][0-9]*)"')
    
    if (issues == '') {
        echo "Commits do not have issue key!!!"
        return null
    }
    
    echo "Original issues: ${issues}"
    issues = issues.split('\n')
    return issues.toList().unique()
}

def getReleaseTag() {
    // return shell('git tag -l --points-at HEAD')
    // return shell('git describe --tags')
    return "11.3.67"
}

//@NonCPS
def addCommentToJiraIssues(jiraIssues, commentText) {
    def comment = [ body: commentText ]
    def status = true
    jiraIssues.each { issue ->
        def response = jiraAddComment idOrKey: issue, input: comment
        if (!response.successful) {
            echo "ERROR: " + response.error
            status = false
        }
        echo response.data.toString()
    }
    
    return status
}

def addReleaseTagToJiraIssues(jiraIssues, releaseTag) {
    if (!jiraIssues || jiraIssues.empty) {
        echo "No Jira issues"
        return true
    }
    
    def modIssue = [fields: [ customfield_10007: ["${releaseTag}"],
                              customfield_10008: ['11.3.0.14175']
                            ]
                   ]
    def status = true
    jiraIssues.each { issue ->
        def response = jiraEditIssue idOrKey: issue, issue: modIssue
        if (!response.successful) {
            echo response.error
            status = false
        }
        echo response.data.toString()
    }
    
    return status
}

def resolveJiraIssues(jiraIssues) {
    def transition = [ transition: [id: '31'] ]
    //def transition = [ transition: [name: 'Done'] ]
    def status = true
    jiraIssues.each { issue ->
        def response = jiraTransitionIssue idOrKey: issue, input: transition
        if (!response.successful) {
            echo response.error
            status = false
        }
        echo response.data.toString()
        
        response = jiraGetIssue idOrKey: issue
        //echo response.data.toString()
        if (!response.successful) {
            echo response.error
            status = false
        }
        else if (response.data && response.data.fields.issuetype.name == 'Bug') {
            def reporter = response.data.fields.reporter
            def modIssue = [fields: [ assignee: reporter ]]
            response = jiraEditIssue idOrKey: issue, issue: modIssue
            if (!response.successful) {
                echo response.error
                status = false
            }
            echo response.data.toString()
            def comment = [ body: "Fix ready for verification!" ]
            response = jiraAddComment idOrKey: issue, input: comment
            if (!response.successful) {
                echo response.error
                status = false
            }
            echo response.data.toString()
        }
    }
    
    return status
}

def createJiraIssue(summary, description) {
    def newIssue = [fields: [ // id or key must present for project.
                               project: [key: 'PE'],
                               summary: summary,
                               description: description,
                               issuetype: [name: 'Bug'],
                               assignee: [name: 'ptt']
                            ]
                  ]
    def status = true
    def response = jiraNewIssue issue: newIssue
    if (!response.successful) {
            echo response.error
            return false
    }

    echo response.data.toString()
    return status
}

def getJiraIssuesInBuild(buildNo) {
    def response = jiraJqlSearch jql: "PROJECT = PE AND cf[10007] = ${buildNo}"
    
    def issues = []
    if (response.successful && response.data.total > 0) {
        echo "total: ${response.data.total}"
        response.data.issues.each { issue ->
            //echo issue.key
            issues.add(issue.key)
        }
    }
    else {
        echo response.error
    }

    return issues
}

def getJiraIssueReporter(issueKey) {
    def issue = jiraGetIssue idOrKey: issueKey
    return issue.data.fields.reporter
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
                echo "pre-build:"
                sh('printenv | sort')
            }
        }
        stage('build') {
            steps {
                echo "Build:"        
                // sh 'mvn --version'
                script {
                    def issues = getJiraIssuesInBuild('11.3.67')
                    echo issues.toString()
                    def reporter = getJiraIssueReporter('PE-1')
                    echo reporter.toString()
                }
            }
        }
    }
    post {
        always {
            echo "Post actions:"
            script {
                changes = getChangeString(currentBuild.changeSets)
                echo changes
            }
        }
        success {
            echo "Build is successful"
            script {
                def issues = getJiraIssuesFromCommits()
                def tag = getReleaseTag()
                echo "All Jira issues: ${issues}"
                echo "Tag: ${tag}"
                def status = addReleaseTagToJiraIssues(issues, tag)
                //status |= addCommentToJiraIssues(issues, tag)
                status |= resolveJiraIssues(issues)
                if (status != true) {
                    echo "Failed doing Jira stuff, sending e-mail"
                    // sendMail, issues, tag, need to manually run a script to update Jira
                }
            }
        }
        unstable {
            echo "Build is unstable"
        }
        failure {
            echo "Build has failed"
            script {
                def summary = "Jenkins and Jira integration for platform build: auto-created on build failure"
                def description = "Jenkins build failure"
                def status = true     // createJiraIssue(summary, description)
                if (status != true) {
                    echo "Failed creating Jira issue, sending e-mail"
                    // sendMail, build#, need to manually create Jira issue
                }
            }
        }
        changed {
            echo "Build completion status has changed"
        }
    }
}
