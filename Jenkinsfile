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
                sh 'ls -lart /usr/local/bin/'
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
                def serverInfo = jiraGetServerInfo()
                echo serverInfo.data.toString()
            }
        }
    }
}
