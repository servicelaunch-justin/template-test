[runtime_public_nodes]
%{ for addr in public_ips ~}
${addr} ansible_ssh_user=ec2-user
%{ endfor ~}

[runtime_worker_nodes]
%{ for addr in worker_ips ~}
${addr} ansible_ssh_user=ec2-user
%{ endfor ~}