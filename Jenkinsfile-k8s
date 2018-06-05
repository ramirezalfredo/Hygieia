pipeline {
  agent {
    kubernetes {
      label 'buildpod'
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: some-label-value
spec:
  containers:
  - name: maven
    image: maven:3.5.3-jdk-8
    command:
    - cat
    tty: true
"""
    }
  }
  stages {
    stage('Build API') {
      steps {
        container('maven') {
          sh 'apt-get update'
          /*
          sh 'curl -sL https://deb.nodesource.com/setup_8.x | bash -'
          sh 'apt-get install -y nodejs'
          sh 'npm install -g bower'
          sh 'npm install -g gulp'
          */
          sh 'mvn install'
          sh 'mvn clean package -DskipTests -pl api docker:build'
          sh 'echo aqui deberia hacer el push de la imagen de docker'
        }
      }
    }
  }
}
