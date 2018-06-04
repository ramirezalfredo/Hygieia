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
    stage('Run maven') {
      steps {
        container('busybox') {
          sh 'npm install -g npm'
          sh 'npm install -g bower'
          sh 'npm install -g gulp'
        }
        container('maven') {
          sh 'mvn clean install package'
        }
      }
    }
  }
}
