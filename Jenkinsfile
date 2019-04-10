def shell(cmd) {
    return sh(script: cmd, returnStdout: true).trim()
}

def getJiraIssuesFromCommits() {
    //return shell('git log --oneline ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}..${GIT_COMMIT} | cut -d " " -f 2').split('\n')
    def issues = shell('git log --oneline ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}..${GIT_COMMIT} | grep -oE "([A-Z]+-[1-9][0-9]*)"').split('\n')
    echo "Original issues: ${issues}"
    return issues.toList().unique()
}

def getReleaseTag() {
    // return shell('git tag -l --points-at HEAD')
    // return shell('git describe --tags')
    return "11.3.67"
}

//@NonCPS
def addJiraComment(jiraIssues, releaseTag) {
    def comment = [ body: "Integrated into build: ${releaseTag}" ]
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

def resolveJiraIssue(jiraIssues) {
    def transition = [ transition: [id: '31'] ]
    def status = true
    jiraIssues.each { issue ->
        def response = jiraTransitionIssue idOrKey: issue, input: transition
        if (!response.successful) {
            echo response.error
            status = false
        }
        echo response.data.toString()
        
        reponse = jiraGetIssue idOrKey: issue
        if (!response.successful) {
            echo response.error
            status = false
        }
        echo response.data.toString()
        
        if (reponse.data.jiraGetType() == Bug) {
            def reporter = reponse.data.jiraGetReporter()
            modIssue = [fields: [ // id or key must present for project.
                                 project: [key: 'PE'],
                                 assignee: [reporter]
                                ]
                       ]
            reponse = jiraEditIssue idOrKey: issue, issue: modIssue
            if (!response.successful) {
                echo response.error
                status = false
            }
            echo response.data.toString()
        }
    }
    
    return status
}

def addReleaseTagToJiraIssue(jiraIssues, releaseTag) {
    def modIssue = [fields: [ // id or key must present for project.
                               project: [key: 'PE'],
                               customfield_10007: ["${releaseTag}"],
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
    }
    
    echo response.data.toString()
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
    def response = jiraJqlSearch jql: "PROJECT = PE AND customfield_10007 = ${buildNo}"
    //def reponse = jiraJqlSearch jql: 'PROJECT = PE AND type = Bug'
    def issues = []
    if (response.successful) {
        echo "total: ${reponse.data.total}"
        reponse.data.issues.each { issue ->
            echo issue.key
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
                def status = addJiraComment(issues, tag)
                status = status | addReleaseTagToJiraIssue(issues, tag)
                status = status | resolveJiraIssue(issues)
                echo status.toString()
                if (status != true) {
                    echo "Failed doing Jira stuff, sending e-mail"
                    // sendMail, issues, tag
                }
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
