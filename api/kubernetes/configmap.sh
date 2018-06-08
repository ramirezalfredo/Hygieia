#!/bin/bash

kubectl create configmap api-properties --from-file=Hygieia/kubernetes/api.properties
#kubectl run nginx --image=nginx