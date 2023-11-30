%{ for group, hosts in inventories ~}
[${group}]
%{for ip in hosts ~}
${ip}
%{endfor ~}
%{ endfor ~}
  
