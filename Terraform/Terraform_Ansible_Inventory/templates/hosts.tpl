[ansible_dyamic_hosts]
%{ for ip in ansible_dyamic_inv ~}
${ip}
%{ endfor ~}