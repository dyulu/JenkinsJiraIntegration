pipeline {
    agent any
    
    //agent {
    //    docker { image 'maven:latest' }
    //}
    //agent { dockerfile true }
    
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
                echo "Commit for this build: $GIT_COMMIT"
                echo "Commit for previous successful build: $GIT_PREVIOUS_COMMIT"
                echo "All Jira issues:"
                sh 'git log --oneline ${GIT_PREVIOUS_COMMIT}..${GIT_COMMIT} | cut -d " " -f 2'
                //sh 'mvn --version'
            }
        }
        stage('JIRA') {
            steps {
                script {
                    serverInfo = jiraGetServerInfo()
                    echo serverInfo.data.toString()
                    //comment = [ body: 'My test comment' ]
                    //jiraAddComment idOrKey: 'PE-1', input: comment
                }
            }
        }
    }
}
