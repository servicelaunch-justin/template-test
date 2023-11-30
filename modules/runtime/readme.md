
```
terraform init
terraform apply -auto-approve
  ...
Apply complete! Resources: X added, Y changed, 0 destroyed.

Outputs:

main_private_ip = "10.0.1.xxx"
main_public_ip = "aaa.bbb.ccc.ddd"

ssh -A -L 8443:<main_private_ip>:8443 -L 9443:<main_private_ip>:9443 ubuntu@<main_public_ip>

ssh <main_private_ip>

tail -f /var/log/cloud-init-output.log
```

MapR installer web ui: `https://localhost:9443`  
MCS: `https://localhost:8443`

Username: `mapr`   
Password: `mapr`