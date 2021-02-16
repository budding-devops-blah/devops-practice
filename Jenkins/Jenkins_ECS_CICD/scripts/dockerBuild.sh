#!/usr/bin/env bash
DOCKER_REPO=`aws ecr describe-repositories --repository-names <created_repo_name> | grep repositoryUri | cut -d "\"" -f 4`
Docker build --no-cache -t ${DOCKER_REPO}:<docker_tag> .
Docker push ${DOCKER_REPO}:<docker_tag>
