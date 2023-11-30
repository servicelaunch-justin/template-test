---
%{ for playbook_set in playbooks ~}

%{ for playbook in playbook_set ~}
- hosts: ${playbook.host}
  become: true
  roles:
  %{for role in playbook.roles ~}
    - ${role}
  %{endfor ~}
  %{ if playbook.var_files != null}
  vars_files:
  %{for vf in playbook.var_files ~}
    - /opt/ansible/var_files/${vf}  
  %{endfor ~}
  %{ endif ~}

%{ endfor ~}
%{ endfor ~}