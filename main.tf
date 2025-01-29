module "spoke-vpc-a" {
  source = "./modules/spoke-vpc"

  vpc_name                      = "spoke-vpc-a"
  cidr                          = "10.0.0.0/16"
  instance_tenancy              = "default"
  enable_dns_support            = true
  public_subnets                = ["10.0.101.0/24", "10.0.102.0/24"]
  private_subnets               = ["10.0.1.0/24", "10.0.2.0/24"]
  avalibility_zones             = ["${var.region}a", "${var.region}b"]
  multiple_public_route_tables  = true
  multiple_private_route_tables = true
  destination_cidr_block        = "0.0.0.0/0"
  transit_gateway_id            = module.transit_gateway.tgw_id
}

module "spoke-vpc-b" {
  source = "./modules/spoke-vpc"

  vpc_name                      = "spoke-vpc-b"
  cidr                          = "10.102.0.0/16"
  instance_tenancy              = "default"
  enable_dns_support            = true
  public_subnets                = ["10.102.1.0/24", "10.102.2.0/24"]
  private_subnets               = ["10.102.4.0/24", "10.102.5.0/24"]
  avalibility_zones             = ["${var.region}a", "${var.region}b"]
  multiple_public_route_tables  = true
  multiple_private_route_tables = true
  destination_cidr_block        = "0.0.0.0/0"
  transit_gateway_id            = module.transit_gateway.tgw_id
}

module "inspection-vpc" {
  source = "./modules/inspection-vpc"

  vpc_name                      = "inspection-vpc"
  cidr                          = "100.64.0.0/16"
  avalibility_zones             = ["${var.region}a", "${var.region}b"]
  private_subnets               = ["100.64.32.0/19", "100.64.64.0/19"]
  public_subnets                = ["100.64.128.0/19", "100.64.160.0/19"]
  multiple_public_route_tables  = true
  multiple_private_route_tables = true
}

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
      transit_gateway_route_table_id                  = aws_ec2_transit_gateway_route_table.spoke_rt_table.id

    },
    "spoke-vpc-b" = {
      vpc_id                                          = module.spoke-vpc-b.vpc_id
      subnet_ids                                      = module.spoke-vpc-b.private_subnets
      dns_support                                     = "enable"
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = true
      transit_gateway_route_table_id                  = aws_ec2_transit_gateway_route_table.spoke_rt_table.id

    },
    "inspection-vpc" = {
      vpc_id                                          = module.inspection-vpc.vpc_id
      subnet_ids                                      = module.inspection-vpc.private_subnets
      dns_support                                     = "enable"
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = true
      transit_gateway_route_table_id                  = aws_ec2_transit_gateway_route_table.firewall_rt_table.id

    }
  }
}

module "network_firewall" {
  source           = "./modules/network-firewall"
  firewall_name    = "network-firewall"
  vpc_id           = module.inspection-vpc.vpc_id
  endpoint_subnets = module.inspection-vpc.public_subnets

  firewall_policy_name               = "test-firewall-policy"
  stateless_default_actions          = ["aws:pass"]
  stateless_fragment_default_actions = ["aws:drop"]
  stateless_rule_groups = {
    "test-rule-group" = {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.drop_icmp_traffic_fw_rule_group.arn
    },
  }
}
#------------------------------------------------------------------------
# Egress Transit Gateway  Route Table
#------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_route_table" "egress_rt_table" {
  transit_gateway_id = module.transit_gateway.tgw_id
  tags = {
    Name = "egress-route-table"
  }

}

resource "aws_ec2_transit_gateway_route" "inspection_vpc_route" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress_rt_table.id
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.transit_gateway.ec2_transit_gateway_vpc_attachment["inspection-vpc"]["id"]

}

#------------------------------------------------------------------------
# Firewall  Transit Gateway  Route Table
#------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route_table" "firewall_rt_table" {
  transit_gateway_id = module.transit_gateway.tgw_id
  tags = {
    Name = "firewall-route-table"
  }

}

resource "aws_ec2_transit_gateway_route" "spoke_vpc_b_tgw_route" { 
  transit_gateway_attachment_id  = module.transit_gateway.ec2_transit_gateway_vpc_attachment["spoke-vpc-b"]["id"]
  destination_cidr_block         = module.spoke-vpc-b.vpc_cidr_block # Change this 
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall_rt_table.id

}

# resource "aws_ec2_transit_gateway_route" "egress_vpc_attachment" {
#   transit_gateway_attachment_id  = module.transit_gateway.ec2_transit_gateway_vpc_attachment["egress_vpc"]["id"]
#   destination_cidr_block         = "0.0.0.0/0"
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall_rt_table.id

# }

resource "aws_ec2_transit_gateway_route" "spoke_vpc_a_tgw_route" {
  transit_gateway_attachment_id  = module.transit_gateway.ec2_transit_gateway_vpc_attachment["spoke-vpc-a"]["id"]
  destination_cidr_block         = module.spoke-vpc-a.vpc_cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall_rt_table.id

}

#------------------------------------------------------------------------
# Spoke  Transit Gateway  Route Table
#------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route_table" "spoke_rt_table" {
  transit_gateway_id = module.transit_gateway.tgw_id
  tags = {
    Name = "spoke-route-table"
  }

}

resource "aws_ec2_transit_gateway_route" "inspection_vpc_tgw_route" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_rt_table.id
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.transit_gateway.ec2_transit_gateway_vpc_attachment["inspection-vpc"]["id"]

}

resource "aws_networkfirewall_rule_group" "drop_icmp_traffic_fw_rule_group" {
  name     = "drop-icmp-traffic-fw-rule-group"
  capacity = 100
  type     = "STATELESS"

  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              protocols = [1]
              source {
                address_definition = "0.0.0.0/0"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
      }
    }
  }

}