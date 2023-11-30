Serves as the access point to the VPC and configures the other hosts with ansible
mublitple bastion hosts can be created but only the first host will run the ansible playbooks
this is determined with the host_number variable that is templated into the userdata.tpl 

Ansible Inventories expects a list of maps with the form:

[ {group1: [ip1, ip2, .. ],
    group2: [ip3, ip4, ...]} ]

Ansible Playbooks expects a list of maps with the form:

[ {host: group1, 
    roles: [role1, role2, ...], 
        var_files: [file1.yaml, file2.yaml,...] }, {...} ]