###https://www.bogotobogo.com/DevOps/Ansible/Ansible-Terraform-null_resource-local-exec-remote-exec-triggers.php###
provider "aws" {
region = "ap-south-1"
}

resource "aws_instance" "ansible_inventory_test" {
  count = 3
  ami           = "ami-0732b62d310b80e97"
  instance_type = "t2.micro"
  key_name      = "sam_sundar"
  vpc_security_group_ids = ["sg-0b57f7f4160f725d7"]
  subnet_id     = "subnet-086824a143f8a1d6c"
  tags = {
    Name = "ansible_inventory_test_1"
  }
}

resource "null_resource" "ConfigureAnsibleLabelVariable" {
  provisioner "local-exec" {
    command = "echo [Ansible_Hosts:vars] > hosts"
  }
  provisioner "local-exec" {
    command = "echo ansible_ssh_user=ec2-user >> hosts"
  }
  provisioner "local-exec" {
    command = "echo ansible_ssh_private_key_file=/home/ec2-user/sam_sundar.pem >> hosts"
  }
  provisioner "local-exec" {
    command = "echo [Ansible_Hosts] >> hosts"
  }
}

resource "null_resource" "ProvisionRemoteHostsIpToAnsibleHosts" {
  count = 3
  connection {
    type = "ssh"
    user = "ec2-user"
    host = "${element(aws_instance.ansible_inventory_test.*.private_ip, count.index)}"
    private_key = "/home/ec2-user/sam_sundar.pem"
  }
 provisioner "remote-exec" {
  inline = [
     "sudo yum update -y",
     "sudo yum install python-setuptools python-pip -y",
   ]
}
  provisioner "local-exec" {
    command = "echo ${element(aws_instance.ansible_inventory_test.*.private_ip, count.index)} >> hosts"
  }
}