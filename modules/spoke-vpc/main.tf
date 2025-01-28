locals {
  public_subnets_count = length(var.public_subnets)
  private_subnets_count = length(var.private_subnets)
  num_public_route_tables = var.multiple_public_route_tables ? local.public_subnets_count : 1
  num_private_route_tables = var.multiple_private_route_tables ? local.private_subnets_count : 1

}

resource "aws_vpc" "this_spoke_vpc" {
    cidr_block = var.cidr
    instance_tenancy = var.instance_tenancy
    enable_dns_support = var.enable_dns_support
    enable_dns_hostnames = var.enable_dns_hostnames
    tags = merge(
        {Name = var.vpc_name},
        var.vpc_tags,
    )
}

resource "aws_subnet" "this_spoke_public_subnets" {
    count = local.public_subnets_count > 0 ? local.public_subnets_count : 0

    cidr_block = element(var.public_subnets,count.index)
    availability_zone = element(var.avalibility_zones,count.index)
    vpc_id = aws_vpc.this_spoke_vpc.id
    enable_dns64 = var.enable_public_dns64
    map_public_ip_on_launch = var.map_public_ip_on_launch
}

resource "aws_subnet" "this_spoke_private_subnets" {
    count = local.private_subnets_count > 0 ? local.private_subnets_count : 0

    cidr_block = element(var.private_subnets,count.index)
    availability_zone = element(var.avalibility_zones,count.index)
    vpc_id = aws_vpc.this_spoke_vpc.id
    enable_dns64 = var.enable_private_dns64
    private_dns_hostname_type_on_launch = var.private_dns_hostname_type_on_launch
}

resource "aws_route_table" "public_route_table" {
    count = local.public_subnets_count > 0 ? local.num_public_route_tables : 0
    vpc_id = aws_vpc.this_spoke_vpc.id
}

resource "aws_route_table" "private_route_table" {
    count = local.private_subnets_count > 0 ? local.num_private_route_tables : 0
    vpc_id = aws_vpc.this_spoke_vpc.id
}

resource "aws_route_table_association" "public" {
  count = local.public_subnets_count > 0 ? local.public_subnets_count : 0
  subnet_id = element(aws_subnet.this_spoke_public_subnets[*].id,count.index)
  route_table_id = element(aws_route_table.public_route_table[*].id, var.multiple_public_route_tables ? count.index : 0)
}

resource "aws_route_table_association" "private" {
  count = local.private_subnets_count > 0 ? local.private_subnets_count : 0
  subnet_id = element(aws_subnet.this_spoke_private_subnets[*].id,count.index)
  route_table_id = element(aws_route_table.private_route_table[*].id, var.multiple_private_route_tables ? count.index: 0)

}

resource "aws_route" "spoke_vpc_to_tgw" {
  # count = local.num_public_route_tables ? local.public_subnets_count : 1
  count = local.num_public_route_tables > 0 ? local.public_subnets_count : 1
  route_table_id = element(aws_route_table.public_route_table[*].id,count.index)
  destination_cidr_block = var.destination_cidr_block
  transit_gateway_id = var.transit_gateway_id
}