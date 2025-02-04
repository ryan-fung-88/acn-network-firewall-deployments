output "vpc_id" {
  value = aws_vpc.this_spoke_vpc.id
}

output "public_subnets" {
  value = aws_subnet.this_spoke_public_subnets[*].id
}

output "private_subnets" {
  value = aws_subnet.this_spoke_public_subnets[*].id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this_spoke_vpc.cidr_block
}