pipeline {
     // Assign to docker slave(s) label, could also be 'any'
    /*
    agent {
        label 'docker' 
    }
    */
    agent any
      
    stages {
        stage('Initialize')
        {
            env.PATH = "/usr/local/bin"
        }
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
