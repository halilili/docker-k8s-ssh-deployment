#!/bin/bash
sed "s/tagVersion/$1/g" k8s/deployment.yml > k8s/node-app-pod.yml
