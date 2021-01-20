## Terraform Remote-Exec for Oracle Java installation

### Create an EC2 instance

```json
resource "aws_instance" "test" {
  ami           = "ami-0732b62d310b80e97"
  instance_type = "t2.micro"
  key_name      = "sam_sundar"
  vpc_security_group_ids = ["sg-0b57f7f4160f725d7"]
  subnet_id     = "subnet-086824a143f8a1d6c"
  tags = {
    Name = "remote-exec-provisioner"
  }
  
}
```

### Create a null resource to copy our script and execute it remotely

```json
resource "null_resource" "copy_execute" {
  
    connection {
    type = "ssh"
    host = aws_instance.test.public_ip
    user = "ec2-user"
    private_key = file("sam_sundar.pem")
    }

 
  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }
  
   provisioner "remote-exec" {
    inline = [
      "sudo chmod 777 /tmp/script.sh",
      "sh /tmp/script.sh",
    ]
  }
  
  depends_on = [ aws_instance.test ]
  
  }
```
* We are copying the script.sh file to tmp directory of created resource
```json
provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }
```
* Changing permission of script.sh to make it executable and executing the script.
```json
provisioner "remote-exec" {
    inline = [
      "sudo chmod 777 /tmp/script.sh",
      "sh /tmp/script.sh",
    ]
  }
```

#### Depends ON 
```json
 depends_on = [ aws_instance.test ]
```

* This states that the block of code  "resource "null_resource" "copy_execute" " will execute only after "aws_instance.test" is created

### Script.sh contents
```bash
#! /bin/bash
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u141-b15/336fa29ff2bb4ef291e347e091f7f4a7/jdk-8u141-linux-x64.rpm
sudo yum install -y jdk-8u141-linux-x64.rpm
```
* We are downloading Oracle JDK RPM and installing the Oracle JDK RPM
 > Note: The URL http://download.oracle.com/otn-pub/java/jdk/8u141-b15/336fa29ff2bb4ef291e347e091f7f4a7/jdk-8u141-linux-x64.rpm will work but in future if oracle invokes authentication, kindly change the URL to OpenJDK or Amazon's Coretto JDK

* https://corretto.aws/downloads/latest/amazon-corretto-8-x64-linux-jdk.rpm - Coretto JDK
* java-1.8.0-openjdk-1.8.0.275.b01-1.el8_3.x86_64.rpm - OpenJDK