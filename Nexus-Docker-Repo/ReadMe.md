# Installing & Running Self Hosted and Managed `Nexus Repository Manager` to store Docker Images.

#### We are going to install `Nexus` on any Linux machine by following the below link.

```bash
https://help.sonatype.com/repomanager2/installing-and-running/configuring-nexus-repository-manager-as-a-service
```
> Once the Repo is installed and started, please open the repo with your IP on port 8081. http://<port>:8081. 
> Note: If you're using AWS, make sure all necessary ports are opened in NACL and Security groups.

#### Login into the Nesux and take the admin password from below path and use this as OTP to login and change your admin password.

```bash
cat /opt/sonatype-work/nexus3/admin.password
```
#### Once logged in, please follow below steps to create a repo and store your docker images. 

#### Create a Docker Repository.
* Click the setting button to open Repo Admin page.
* On the left you have a option called `Repositories` where you find default Repositories which were created by Nexus.
* Click on `Create Repository` and choose `docker (hosted)` option, give a unique name for your repo and under Repository Connectors option, click on http connector and mention any port (I choose 10001 since it's a Random port which no other service runs on it.)
> Note: The port which you choose under http connector is your Docker Repo's port and you can access it on that port only. 

##### Now that we have created a repo, let's see how we can tag our images and push to our Self Hosted Nexus Docker Repo.

#### Tagging Docker images 
* First let's set our Repository config in our machine where Docker is running by entering below command. (I'm running on my local hence 127.0.0.1, please use your server's IP if you try to access from different machine).
```bash
docker login 127.0.0.1:10001 (10001 is port configured in http connector)
```
* Once we logged in, we will pull a test hello world docker image from DockerHub by running below command.
 ```bash
 docker pull hello-world
 ```
 * We can tag the hello-world image with our Repo Server's IP and Port number so that Docker knows where to push the image.
 ```bash
 docker tag hello-world 127.0.0.1:10001/test_hello:1.0;
```
 > Ref: https://www.docker.com/blog/how-to-use-your-own-registry/

#### Push and Pull from Nexus Repo
* Now try pushing the image to our Nexus Repo.
```bash
docker push 127.0.0.1:10001/test_hello:1.0
```
* Once the Image is pushed, try pulling the image from Nexus Repo. 
```bash
docker pull 127.0.0.1:10001/test_hello:1.0
```

### (Optional) Nexus Cli.
* Configuring Nexus CLI

``` bash
nexus-cli configure
Enter Nexus Host: http://127.0.0.1:8081
Enter Nexus Repository Name: test_sam_2
Enter Nexus Username: admin
Enter Nexus Password: *******
```
* Check the images in our Repo
```bash
nexus-cli image ls
nginx_sam
Total images: 1
```
* Check Image with their Tags
```bash
nexus-cli image tags -name nginx_sam
1.0
1.1
There are 2 images for nginx_sam
```

```bash
nexus-cli image info -name nginx_sam -tag 1.0
Image: nginx_sam:1.0
Size: 7736
Layers:
	sha256:f7ec5a41d630a33a2d1db59b95d89d93de7ae5a619a3a8571b78457e48266eba	27139373
	sha256:aa1efa14b3bfc78fab92952a716bb9d6bda5de150727297dbd8bda66c933a0f3	26576005
	sha256:b78b95af9b17013ded5fece8819e3cf5279f965d87915667642ae1d7261492cc	602
	sha256:c7d6bca2b8dce72b5765be4c42f907cb0ae1b4e815ecbaf4a2b2f79d3a33fce4	895
	sha256:cf16cd8e71e08dd82075a33f475f2758da3e87f5733f4ead4a5b842f601e0f09	666
	sha256:0241c68333ef9f824a96ccd9cee33848b465c812000d7b1f4bb5b9a611dfe25a	1397
 ``` 
* Create a Lifecycle policy to delete every image and keep only last 4 versions of the image.  
```bash
nexus-cli image delete -name nginx_sam -keep 4
nginx_sam:1.0 image will be deleted ...
nginx_sam:1.0 has been successful deleted
```


##### Ref Links
* > https://www.blog.labouardy.com/cleanup-old-docker-images-from-nexus-repository/

* > https://blog.sonatype.com/cleanup-old-docker-images-from-nexus-repository

* > https://help.sonatype.com/repomanager2/installing-and-running/configuring-nexus-repository-manager-as-a-service
