pipeline {
    //agent any
    agent {
        docker { image 'maven:latest' }
    }
    
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
                sh 'mvn --version'
            }
        }
    }
}
