provider "aws" {
region = "ap-south-1"
}


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