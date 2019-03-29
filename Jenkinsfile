pipeline {
     // Assign to docker slave(s) label, could also be 'any'
    /*
    agent {
        label 'docker' 
    }
    */
    agent any
    stage('Initialize')
    {
        env.PATH = "/usr/local/bin"
    }
      
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
