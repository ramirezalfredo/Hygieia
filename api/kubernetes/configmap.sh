#!/bin/bash

kubectl create configmap api-properties --from-file=Hygieia/kubernetes/application.properties
#kubectl run nginx --image=nginx