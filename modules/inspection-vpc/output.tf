output "vpc_id" {
  value = aws_vpc.this_inspection_vpc.id
}

output "public_subnets" {
  value = aws_subnet.this_inspection_public_subnets[*].id
}

output "private_subnets" {
  value = aws_subnet.this_inspection_private_subnets[*].id
}

output "private_route_tables" {
  value = aws_route_table.private_route_table[*].id
}

output "public_route_tables" {
  value = aws_route_table.public_route_table[*].id
}