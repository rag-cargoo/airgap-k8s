output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = aws_subnet.private.id
}

output "bastion_public_ip" {
  description = "Public IP of bastion"
  value       = aws_instance.bastion.public_ip
}

output "master_private_ip" {
  description = "Private IP of k8s-master"
  value       = aws_instance.master.private_ip
}

output "worker1_private_ip" {
  description = "Private IP of k8s-worker1"
  value       = aws_instance.worker1.private_ip
}
