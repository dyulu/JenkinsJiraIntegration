pipeline {
    agent any
      
    stages {
        stage('pre-build') {
            steps {
                sh 'echo "Hello World!"'
                sh 'echo $PATH'
                sh 'ls -lart /usr/local/bin/'
            }
        }
        stage('build') {
            agent { docker { image 'maven:3-alpine' } }
            steps {
                sh 'echo "Build"'
                sh 'mvn --version'
            }
        }
    }
}
