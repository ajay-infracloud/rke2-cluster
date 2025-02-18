output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of Public Subnets"
  value       = module.vpc.public_subnets
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.vpc.igw_id
}

output "instance_public_ips" {
  description = "Public IPs of RKE Masters"
  value       = aws_instance.rke2_server[*].public_ip
}

