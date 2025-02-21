module "transit_gateway" {
  source = "./modules/transit-gateway"

  create_tgw = true

  vpc_attachments = {
    "spoke-vpc-a" = {
      vpc_id                                          = module.spoke-vpc-a.vpc_id
      subnet_ids                                      = module.spoke-vpc-a.private_subnets
      dns_support                                     = "enable"
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = true
      transit_gateway_route_table_id                  = aws_ec2_transit_gateway_route_table.spoke_route_table.id

    },
    "spoke-vpc-b" = {
      vpc_id                                          = module.spoke-vpc-b.vpc_id
      subnet_ids                                      = module.spoke-vpc-b.private_subnets
      dns_support                                     = "enable"
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = true
      transit_gateway_route_table_id                  = aws_ec2_transit_gateway_route_table.spoke_route_table.id

    },
    "inspection-vpc" = {
      vpc_id                                          = module.inspection-vpc.vpc_id
      subnet_ids                                      = module.inspection-vpc.private_subnets
      dns_support                                     = "enable"
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = true
      transit_gateway_route_table_id                  = aws_ec2_transit_gateway_route_table.firewall_route_table.id

    }
  }
}
#------------------------------------------------------------------------
# Firewall  Transit Gateway  Route Table

resource "aws_ec2_transit_gateway_route_table" "firewall_route_table" {
  transit_gateway_id = module.transit_gateway.tgw_id
  tags = {
    Name = "firewall-route-table"
  }

}

resource "aws_ec2_transit_gateway_route" "spoke_vpc_b_tgw_route" { 
  transit_gateway_attachment_id  = module.transit_gateway.ec2_transit_gateway_vpc_attachment["spoke-vpc-b"]["id"]
  destination_cidr_block         = module.spoke-vpc-b.vpc_cidr_block  
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall_route_table.id

}

resource "aws_ec2_transit_gateway_route" "spoke_vpc_a_tgw_route" {
  transit_gateway_attachment_id  = module.transit_gateway.ec2_transit_gateway_vpc_attachment["spoke-vpc-a"]["id"]
  destination_cidr_block         = module.spoke-vpc-a.vpc_cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall_route_table.id

}

#------------------------------------------------------------------------
# Spoke  Transit Gateway  Route Table

resource "aws_ec2_transit_gateway_route_table" "spoke_route_table" {
  transit_gateway_id = module.transit_gateway.tgw_id
  tags = {
    Name = "spoke-route-table"
  }

}

resource "aws_ec2_transit_gateway_route" "inspection_vpc_tgw_route" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_route_table.id
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.transit_gateway.ec2_transit_gateway_vpc_attachment["inspection-vpc"]["id"]
}

#---------------------------------------------------------------------------
# Inspection VPC Firewall and TGW Route

resource "aws_route" "inspection_vpc_tgw_rt_route" {
  count                  = length(module.inspection-vpc.private_route_tables)
  route_table_id         = element(module.inspection-vpc.private_route_tables,count.index)
  vpc_endpoint_id        = (module.network_firewall.nfw_endpoint)[count.index]
  destination_cidr_block = "0.0.0.0/0"

  depends_on = [ 
    module.network_firewall
 ]
}

resource "aws_route" "inspection_vpc_firewall_route" {
  count                  = length(module.inspection-vpc.public_route_tables)
  route_table_id         = element(module.inspection-vpc.public_route_tables,count.index)
  transit_gateway_id     = module.transit_gateway.tgw_id
  destination_cidr_block = "0.0.0.0/0"

  depends_on = [ 
    module.transit_gateway
   ]
}

#------------------------------------------------------------------------
# Egress Transit Gateway  Route Table

# resource "aws_ec2_transit_gateway_route_table" "egress_rt_table" {
#   transit_gateway_id = module.transit_gateway.tgw_id
#   tags = {
#     Name = "egress-route-table"
#   }

# }

# resource "aws_ec2_transit_gateway_route" "inspection_vpc_route" {
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress_rt_table.id
#   destination_cidr_block         = "0.0.0.0/0"
#   transit_gateway_attachment_id  = module.transit_gateway.ec2_transit_gateway_vpc_attachment["inspection-vpc"]["id"]

# }

# resource "aws_ec2_transit_gateway_route" "egress_vpc_attachment" {
#   transit_gateway_attachment_id  = module.transit_gateway.ec2_transit_gateway_vpc_attachment["egress_vpc"]["id"]
#   destination_cidr_block         = "0.0.0.0/0"
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall_rt_table.id

# }

