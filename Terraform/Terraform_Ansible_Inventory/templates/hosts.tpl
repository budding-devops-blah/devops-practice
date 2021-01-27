[ansible_dyamic_hosts]
%{ for ip in ansible_dyamic_inv ~}
${ip}
%{ endfor ~}

[all:vars]
ansible_ssh_private_key_file = /home/sam/sam_sundar.pem
ansible_ssh_user = ec2-user