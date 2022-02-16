#!/bin/bash
sed "s/tagVersion/$1/g" pods.yml > k8s/node-app-pod.yml
