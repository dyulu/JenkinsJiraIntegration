pipeline {
    agent { docker { image 'maven:3.3.3' } }
    stages {
        stage('pre-build') {
            steps {
                sh 'echo "Hello World!"'
            }
        stage('build') {
            steps {
                sh 'mvn --version'
            }
        }
    }
}
