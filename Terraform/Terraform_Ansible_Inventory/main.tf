provider "aws" {
region = "ap-south-1"
}

resource "aws_instance" "ansible_inventory_test" {
  ami           = "ami-0732b62d310b80e97"
  instance_type = "t2.micro"
  key_name      = "sam_sundar"
  vpc_security_group_ids = ["sg-0b57f7f4160f725d7"]
  subnet_id     = "subnet-086824a143f8a1d6c"
  tags = {
    Name = "ansible_inventory_test_1"
  }
  
}

#####################################
#generate inventory file for Ansible#
#####################################
resource "local_file" "ansible_dyamic_inventory_file" {
  content = templatefile("${path.module}/templates/hosts.tpl",
    {
      ansible_dyamic_inv = aws_instance.ansible_inventory_test.*.private_ip
    }
  )
  filename = "../ansible_dyamic_inventory_file.txt"
}