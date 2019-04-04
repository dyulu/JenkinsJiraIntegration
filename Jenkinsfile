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
                //sh 'mvn --version'
            }
        }
        stage('JIRA') {
            steps {
                script {
                    serverInfo = jiraGetServerInfo()
                    echo serverInfo.data.toString()
                    comment = [ body: 'My test comment' ]
                    jiraAddComment idOrKey: 'PE-1', input: comment
                }
            }
        }
    }
}
