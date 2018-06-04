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
    image: maven:alpine
    command:
    - cat
    tty: true
  - name: node
    image: node:alpine
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
          sh 'apk add nodejs'
          sh 'npm install -g bower'
          sh 'npm install -g gulp'
          sh 'mvn install'
          sh 'mvn clean package -pl api docker:build'
          sh 'echo aqui deberia hacer el push de la imagen de docker'
        }
      }
    }
  }
}
