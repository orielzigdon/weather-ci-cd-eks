output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private.*.id
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "nat_instance_primary_eni_id" {
  value = aws_instance.nat_instance.primary_network_interface_id
}
