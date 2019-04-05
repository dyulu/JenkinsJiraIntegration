def shell(cmd) {
    return sh(script: cmd,
             returnStdout: true).trim()
}

def getIssues() {
    return shell('git log --oneline ${GIT_PREVIOUS_COMMIT}..${GIT_COMMIT} | cut -d " " -f 2').split('\n')
}

def getTag() {
    // return shell('git tag -l --points-at HEAD')
    return shell('git describe --tags')
}

@NonCPS
def addJiraComment(jiraIssues, tag) {
    comment = [ body: "Integrated into build: ${tag}" ]
    jiraIssues.each { issue ->
        jiraAddComment idOrKey: issue, input: comment
    }
}

@NonCPS
def resolveJiraIssue(jiraIssues) {
    transition = [ transition: [name: 'RESOLVED'] ]
    jiraIssues.each { issue ->
        jiraTransitionIssue idOrKey: issue, input: transition
    }
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
            //script {
                issues = getIssues()
                tag = getTag()
                echo "All Jira issues: ${issues}"
                echo "Tag: ${tag}"
                addJiraComment(issues, tag)
                resolveJiraIssue(issues)
            //}
        }
        unstable {
            echo "Build is unstable"
        }
        failure {
            echo "Build has failed"
        }
        changed {
            echo "Build has changed"
            echo "currentBuild.changeSets"
        }
    }
}
