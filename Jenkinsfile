pipeline {
    agent any
      
    stages {
        stage('pre-build') {
            steps {
                sh 'echo "Hello World!"'
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
