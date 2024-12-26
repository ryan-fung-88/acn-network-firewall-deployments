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
    count = length(var.public_subnets) > 0 ? len(var.public_subnets) : 0

    cidr_block = element(var.public_subnets,count.index)
    availability_zone = element(var.avalibility_zones,count.index)
    vpc_id = aws_vpc.this_spoke_vpc.id

}

resource "aws_subnet" "this_spoke_private_subnets" {
    count = length(var.private_subnets) > 0 ? len(var.private_subnets) : 0

    cidr_block = element(var.private_subnets,count.index)
    availability_zone = element(var.avalibility_zones,count.index)
    vpc_id = aws_vpc.this_spoke_vpc.id

}