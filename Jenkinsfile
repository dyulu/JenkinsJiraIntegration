pipeline {
      // Assign to docker slave(s) label, could also be 'any'
     agent {
        label 'docker' 
    }
    //agent any
    
    stages {
        agent { docker { label 'docker' image 'maven:3-alpine' } }
        
        stage('pre-build') {
            steps {
                sh 'echo "Hello World!"'
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
