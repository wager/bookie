output "public_subnet_id" {
  value       = aws_subnet.public.id
  description = "Identifier of the public subnet."
}

output "vagrant_security_group_id" {
  value       = aws_security_group.vagrant.id
  description = "Identifier of the Vagrant security group."
}
