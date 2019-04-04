def shell(cmd) {
    return sh(script: cmd,
             returnStdout: true).trim()
}

@NonCPS // has to be NonCPS or the build breaks on the call to .each
def addJiraComment(jiraIssues, comment) {
    jiraIssues.each { issue ->
        jiraAddComment idOrKey: ${issue}, input: comment
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
        stage('JIRA') {
            steps {
                script {
                    issues = shell('git log --oneline ${GIT_PREVIOUS_COMMIT}..${GIT_COMMIT} | cut -d " " -f 2')
                    tag = shell('git tag -l --points-at HEAD')
                    sh 'git log --oneline ${GIT_PREVIOUS_COMMIT}..${GIT_COMMIT} | cut -d " " -f 2'
                    sh 'git tag -l --points-at HEAD'
                    echo "All Jira issues: ${issues}"
                    echo "Tag: ${tag}"
                    serverInfo = jiraGetServerInfo()
                    echo serverInfo.data.toString()
                    addJiraComment(${issues}, ${tag})
                    //comment = [ body: 'My test comment' ]
                    //jiraAddComment idOrKey: 'PE-1', input: comment
                }
            }
        }
    }
}
