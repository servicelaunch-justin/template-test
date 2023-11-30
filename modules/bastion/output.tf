output "host_ips" {
  value = aws_instance.bastion_host.*.public_ip
}