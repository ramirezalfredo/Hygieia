#!/binbash

# creates repos in ECR
aws ecr create-repository --repository-name hygieia-ui
aws ecr create-repository --repository-name hygieia-github-scm-collector
aws ecr create-repository --repository-name hygieia-bitbucket-scm-collector
aws ecr create-repository --repository-name hygieia-jenkins-build-collector
aws ecr create-repository --repository-name hygieia-apiaudit
aws ecr create-repository --repository-name hygieia-api

#tag images to be pushed
docker tag hygieia-ui:latest 537899582775.dkr.ecr.us-east-2.amazonaws.com/hygieia-ui:latest
docker tag hygieia-github-scm-collector:latest 537899582775.dkr.ecr.us-east-2.amazonaws.com/hygieia-github-scm-collector:latest
docker tag hygieia-bitbucket-scm-collector:latest 537899582775.dkr.ecr.us-east-2.amazonaws.com/hygieia-bitbucket-scm-collector:latest
docker tag hygieia-jenkins-build-collector:latest 537899582775.dkr.ecr.us-east-2.amazonaws.com/hygieia-jenkins-build-collector:latest
docker tag hygieia-apiaudit:latest 537899582775.dkr.ecr.us-east-2.amazonaws.com/hygieia-apiaudit:latest
docker tag hygieia-api:latest 537899582775.dkr.ecr.us-east-2.amazonaws.com/hygieia-api:latest

#push images
push 537899582775.dkr.ecr.us-east-2.amazonaws.com/hygieia-ui:latest
push 537899582775.dkr.ecr.us-east-2.amazonaws.com/hygieia-github-scm-collector:latest
push 537899582775.dkr.ecr.us-east-2.amazonaws.com/hygieia-bitbucket-scm-collector:latest
push 537899582775.dkr.ecr.us-east-2.amazonaws.com/hygieia-jenkins-build-collector:latest
push 537899582775.dkr.ecr.us-east-2.amazonaws.com/hygieia-apiaudit:latest
push 537899582775.dkr.ecr.us-east-2.amazonaws.com/hygieia-api:latest