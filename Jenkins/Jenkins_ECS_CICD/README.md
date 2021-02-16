# springboot-autodeployment
Content and Code related to Springboot application deployment using jenkins

# This repository contains below files : 

1. Dockerfile  : Docker file template to build docker image using the jar file build from maven.
2. dockerBuild.sh : Shell script that we can use to build docker image of spring boot application.
3. template.json  : Task configuration to update ECS task definition.
4. deployToECS.sh : Shell script that we can use to update task definition and ECS service using template.json as task specifications.
