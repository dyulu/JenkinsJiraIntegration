def shell(cmd) {
    return sh(script: cmd,
             returnStdout: true).trim()
}

def getIssues() {
    return shell('git log --oneline ${GIT_PREVIOUS_COMMIT}..${GIT_COMMIT} | cut -d " " -f 2').split('\n')
}

def getTag() {
    // return shell('git tag -l --points-at HEAD')
    // return shell('git describe --tags')
    return "11.3.67"
}

@NonCPS
def addJiraComment(jiraIssues, tag) {
    comment = [ body: "Integrated into build: ${tag}" ]
    jiraIssues.each { issue ->
        response = jiraAddComment idOrKey: issue, input: comment
        echo response.successful.toString()
        echo response.data.toString()
    }
}

@NonCPS
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
                               customfield_10008: ['11.3.0.14176']
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
                sh 'echo "Hello World!"'
                sh 'echo $PATH'
            }
        }
        stage('build') {
            steps {
                sh 'echo "Build"'
                echo "Git branch: $GIT_BRANCH"
                echo "Commit for this build: $GIT_COMMIT"
                echo "Commit for previous successful build: $GIT_PREVIOUS_COMMIT"
                //sh 'mvn --version'
            }
        }
    }
    post {
        always {
            echo "Post actions:"
        }
        success {
            echo "Build is successful"
            script {
                issues = getIssues()
                tag = getTag()
                echo "All Jira issues: ${issues}"
                echo "Tag: ${tag}"
                addJiraComment(issues, tag)
                addReleaseTagToJiraIssue(issues, tag)
                resolveJiraIssue(issues)
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
            echo "Build has changed"
            echo "${currentBuild.changeSets}"
        }
    }
}
