def shell(cmd) {
    return sh(script: "${cmd} || true", returnStdout: true).trim()
}

def getJiraIssuesFromCommits() {
    if (GIT_PREVIOUS_SUCCESSFUL_COMMIT == GIT_COMMIT)
        return null
    
    //return shell('git log --oneline ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}..${GIT_COMMIT} | cut -d " " -f 2').split('\n')
    def issues = shell('git log --oneline ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}..${GIT_COMMIT} | grep -oE "([a-zA-Z]+-[1-9][0-9]*)"')
    return issues.toUpperCase().split('\n').toList().unique()
}

def getReleaseTag() {
    // return shell('git tag -l --points-at HEAD')
    // return shell('git describe --tags')
    //return "11.3.67"
    return "12.0.58"
}

//@NonCPS
def addCommentToJiraIssues(jiraIssues, commentText) {
    if (!jiraIssues) {
        echo "No Jira issues"
        return true
    }
    
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
    if (!jiraIssues) {
        echo "No Jira issues"
        return true
    }
    echo "No op"
    return true
    
    def status = true
    jiraIssues.each { issue ->
        def response = jiraGetIssue idOrKey: issue
        //echo response.data.toString()
        if (!response.successful) {
            echo response.error
            status = false
        }
        else if (response.data) {
            def cf17423 = response.data.fields.customfield_17423
            if (cf17423) {
                cf17423.add(releaseTag)
            } else {
                cf17423 = [releaseTag]
            }
            def modIssue = [fields: [ customfield_17423: cf17423 ]]
            response = jiraEditIssue idOrKey: issue, issue: modIssue
            if (!response.successful) {
                echo response.error
                status = false
            }
        }
    }
    
    return status
}

def resolveJiraIssues(jiraIssues, releaseTag) {
    if (!jiraIssues) {
        return true
    }
    
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
        else if (response.data) {
            def isBug = false
            def cf17423 = response.data.fields.customfield_17423
            if (cf17423) {
                cf17423.add(releaseTag)
            } else {
                cf17423 = [releaseTag]
            }
            def modIssue = null
            if (response.data.fields.issuetype.name == 'Bug') {
                isBug = true
                def reporter = response.data.fields.reporter
                modIssue = [fields: [ customfield_17423: cf17423,
                                      assignee: reporter
                                    ]
                           ]
            } else {
                modIssue = [fields: [ customfield_17423: cf17423 ]]
            }
            
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
    echo "No op"
    return true
    
    def newIssue = [fields: [ // id or key must present for project.
                               project: [key: 'PE'],
                               summary: summary,
                               description: description,
                               issuetype: [name: 'Bug'],
                               assignee: [name: 'ptt']
                            ]
                  ]

    def response = jiraNewIssue issue: newIssue
    if (!response.successful) {
            echo response.error
            return false
    }

    echo response.data.toString()
    return true
}

def getJiraIssuesInBuild(buildNo) {
    def response = jiraJqlSearch jql: "PROJECT = PE AND cf[17423] = ${buildNo}"
    
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
def getChangesInBuild(build, changes) {
    def changeSets = build.changeSets
    for (int i = 0; i < changeSets.size(); i++) {
        echo "build ${build.id}, i ${i}"
        def items = changeSets[i].items
        for (int j = 0; j < items.length; j++) {
            echo "j ${j}, ${items[j].author}"
            def commitmsg = items[j].msg.toUpperCase()
            def issues = commitmsg =~ /([A-Z]+-[1-9][0-9]*)/
            issues.each { changes.add(it[0]) }
        }
    }

    echo changes.toString()
}

@NonCPS
def getChangesSinceLastSuccessfulBuild() {
    def changes = []
    def build = currentBuild
    while (build) {
        getChangesInBuild(build, changes)
        build = build.previousBuild
        if (!build || build.result == 'SUCCESS') {
            break
        }
    }
    
    return changes.unique()
}
    
pipeline {
    //agent any
    
    agent {
        node { label 'SCS_ubuntu' }
    }
    
    /*
    agent {
        docker { image 'maven:latest' }
    }
    agent { dockerfile true }
    */
    
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
                    
                    //def reporter = getJiraIssueReporter('PE-5432')
                    //echo reporter.toString()
                }
            }
        }
    }
    post {
        always {
            echo "Post actions:"
            archiveArtifacts artifacts: "Jenkinsfile", allowEmptyArchive: true
            /*
            script {
                changes = getChangesSinceLastSuccessfulBuild()
                echo "All Jira issues from change log: ${changes}"
            }
            */
        }
        success {
            echo "Build is successful"
            script {
                def issues = getJiraIssuesFromCommits()
                def tag = getReleaseTag()
                echo "All Jira issues: ${issues}"
                echo "Tag: ${tag}"
                try {
                    // if (!resolveJiraIssues(issues, tag)) {
                    if (!addReleaseTagToJiraIssues(issues, tag)) {
                        echo "Failed doing Jira stuff, sending e-mail with issues and tag"
                        // sendMail, issues, tag; need to manually run a script to update Jira
                    }
                } catch (error) {
                    echo "Failed doing Jira stuff, sending e-mail with issues, tag and error"
                    echo error.toString()
                    // sendMail, issues, tag, error; need to manually run a script to update Jira
                }
            }
        }
        unstable {
            echo "Build is unstable"
        }
        failure {
            echo "Build has failed"
            script {
                def job = JOB_NAME.split('/')[0]
                def logfile = "${JENKINS_HOME}/jobs/${job}/branches/${BRANCH_NAME}/builds/${BUILD_NUMBER}/log"
                def summary = "Jenkins and Jira integration for platform build: auto-created on build ${BUILD_NUMBER} failure"
                def description = "BUILD_URL: ${BUILD_URL}\n\nConsole log file: ${logfile}\n\n"
                description += shell("grep -B4 'command not found' ${logfile}")
                print description
                
                try {
                    if (!createJiraIssue(summary, description)) {
                        echo "Failed creating Jira issue, sending e-mail"
                        // sendMail, build#; need to manually create Jira issue
                    }
                } catch (error) {
                    echo "Failed doing Jira stuff, sending e-mail with issues, tag and error"
                    echo error.toString()
                    // sendMail, build#, error; need to manually run a script to update Jira
                }
            }
        }
        changed {
            echo "Build completion status has changed"
        }
    }
}
