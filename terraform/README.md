# GL-DevOps-Challenge

Welcome to the GL DevOps Challence to implement Hygieia `https://github.com/capitalone/Hygieia` on Docker containers.

In this directory you may find the terraform IaC files (challenge.tf and variables.tf) needed to build:

* Jenkins t2.micro instance
* MongoDB t2.micro instance
* Kubernetes Master t2.small instance
* Kubernetes Worker x 2 t2.small instances

Ansible was used as the Configuration Management for this project, and the files are:

* playbook.yml
* group_vars/*
* roles/*
* templates/*

For the playbook, created a single `playbook.yml` file with tags that are called from a `local-exec` in the terraform configuration file, specifically in `challenge.tf`.

The Kubernetes Cluster generation is fully automated, with the exception of the client certificate for the jenkins-kubernetes-plugin, which is a PKCS12 key with the admin credentials of the cluster.

The Jenkins setup process is not automated, but shows the initial wizard screen, and the Kubernetes Jenkins plugin should be installed and configured manually.

The idea behind this, is to use the Kubernetes cluster for the builds. The pipeline  launches a Pod (buildpod-*) with the necessary containers in order to build the parts of the project.  A Jenkinsfile (declarative pipeline) is provided at the root of this repository `https://github.com/ramirezalfredo/Hygieia`.