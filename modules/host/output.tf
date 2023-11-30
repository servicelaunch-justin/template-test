output "host_ips" {
  value = {
    public = aws_instance.host.*.public_ip
    private = aws_instance.host.*.private_ip
  }
}

output "playbook" {
  value = [{host = var.group_name
            roles = var.roles
            var_files = var.var_files  }]
         
}

output inventory {
  value = {"${var.group_name}" = aws_instance.host.*.private_ip}
}