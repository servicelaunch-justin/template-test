output "main_public_ip" {
  description = "Contains the main public IP address"
  value       = aws_instance.public-nodes.*.public_ip
}
/*
output "worker_nodes" {
  description = "Contains the worker private IP addresss"
  value = tomap({
    "name" = aws_instance.worker-nodes.*.name
    "ip"   = aws_instance.worker-nodes.*.private_ip
  })

}
*/

/*
  Ansible
*/

output "ansible" {
  value = { "playbook" = templatefile("${path.module}/templates/playbook.tpl", { public_ips = aws_instance.public-nodes.*.public_ip, worker_ips = aws_instance.worker-nodes.*.private_ip })
    "inventory" = templatefile("${path.module}/templates/inventory.tpl", { public_ips = aws_instance.public-nodes.*.public_ip, worker_ips = aws_instance.worker-nodes.*.private_ip })
  "name" = "runtime"
  "host_vars" = {} }
}