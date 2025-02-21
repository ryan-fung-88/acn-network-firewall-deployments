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
