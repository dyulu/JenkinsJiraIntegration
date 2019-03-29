pipeline {
    //agent { docker { image 'maven:3.3.3' } }
    agent any
    stages {
        stage('pre-build') {
            steps {
                sh 'echo "Hello World!"'
            }
        }
        stage('build') {
            steps {
                sh 'echo "Build"'
                //sh 'mvn --version'
            }
        }
    }
}
