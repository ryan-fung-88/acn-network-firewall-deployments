output "vpc_id" {
  value = aws_vpc.this_inspection_vpc.id
}

output "public_subnets" {
  value = aws_subnet.this_inspection_public_subnets[*].id
}