pipeline {
      // Assign to docker slave(s) label, could also be 'any'
     agent {
        label 'docker' 
    }
    //agent any
    
    stages {
        stage('pre-build') {
            steps {
                sh 'echo "Hello World!"'
            }
        }
        stage('build') {
            agent { docker { label 'docker' image 'maven:3-alpine' } }
            steps {
                sh 'echo "Build"'
                sh 'mvn --version'
            }
        }
    }
}
