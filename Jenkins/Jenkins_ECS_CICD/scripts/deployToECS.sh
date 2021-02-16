#!/usr/bin/env bash

# Below script will look for task defnition template in /var/lib/jenkins/template.json path
# The template.json file is provided in this repository

dockerRepo=`aws ecr describe-repositories --repository-name jenkins-test-repo --region us-east-1 | grep repositoryUri | cut -d "\"" -f 4`
dockerTag=`aws ecr list-images --repository-name jenkins-test-repo --region us-east-1 | grep imageTag | head -n 1 | cut -d "\"" -f 4`
sed -e "s;DOCKER_IMAGE_NAME;${repositoryURI};g" scripts/template.json > taskDefinition.json
aws ecs register-task-definition --family jenkins-test --cli-input-json file://taskDefinition.json --region us-east-1
revision=`aws ecs describe-task-definition --task-definition jenkins-test --region us-east-1 | grep "revision" | tr -s " " | cut -d " " -f 3`
aws ecs update-service --cluster test-cluster --service test-service --task-definition jenkins-test:${revision} --desired-count 1
