module "spoke-vpc-a" {
  source = "./modules/spoke-vpc"
  
  vpc_name = "spoke-vpc-a"
  cidr = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  avalibility_zones = ["${var.region}a", "${var.region}b"]
  multiple_public_route_tables = true
  multiple_private_route_tables = true
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id = module.transit_gateway.tgw_id
}

module "spoke-vpc-b" {
  source = "./modules/spoke-vpc"
  
  vpc_name = "spoke-vpc-b"
  cidr = "10.102.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  public_subnets = ["10.102.1.0/24", "10.102.2.0/24"]
  private_subnets = ["10.102.4.0/24", "10.102.5.0/24"]
  avalibility_zones = ["${var.region}a", "${var.region}b"]
  multiple_public_route_tables = true
  multiple_private_route_tables = true
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id = module.transit_gateway.tgw_id
}

module "inspection-vpc" {
  source = "./modules/inspection-vpc"

  vpc_name = "inspection-vpc"
  cidr            = "100.64.0.0/16"
  avalibility_zones = ["${var.region}a", "${var.region}b"]
  private_subnets = ["100.64.32.0/19", "100.64.64.0/19"]
  public_subnets  = ["100.64.128.0/19", "100.64.160.0/19"]
  multiple_public_route_tables = true
  multiple_private_route_tables = true
}

module "transit_gateway" {
  source = "./modules/transit-gateway"
  
  create_tgw = true

  vpc_attachments = {
    "spoke-vpc-a" = {
      vpc_id = module.spoke-vpc-a.vpc_id
      subnet_ids = module.spoke-vpc-a.private_subnets
      dns_support = "enable"
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation= true
    },
    "spoke-vpc-b" = {
      vpc_id = module.spoke-vpc-b.vpc_id
      subnet_ids = module.spoke-vpc-b.private_subnets
      dns_support = "enable"
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation= true
    },
    "inspection-vpc" = {
      vpc_id = module.inspection-vpc.vpc_id
      subnet_ids = module.inspection-vpc.private_subnets
      dns_support = "enable"
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation= true
    }
  }
}

module "network_firewall" {
  source = "./modules/network-firewall"
  firewall_name = "network_firewall"
  vpc_id = module.inspection-vpc.vpc_id
  endpoint_subnets = module.inspection-vpc.public_subnets

  firewall_policy_name = "test_firewall_policy"
  stateless_default_actions = ["aws:pass"]
  stateless_fragment_default_actions = ["aws:drop"]
  stateless_rule_groups = {
    "test-rule-group" = {
        priority= 1
        resource_arn = aws_networkfirewall_rule_group.drop_icmp_traffic_fw_rule_group.arn
    },
  }
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