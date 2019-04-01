pipeline {
    agent any
      
    stages {
        stage('pre-build') {
            steps {
                sh 'echo "Hello World!"'
                sh 'echo $PATH'
                sh 'echo ${env.PATH}'
                sh 'env.PATH="/usr/local/bin:${env.PATH}"'
                sh 'echo ${env.PATH}'
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
