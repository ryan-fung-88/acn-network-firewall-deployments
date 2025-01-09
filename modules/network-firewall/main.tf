resource "aws_networkfirewall_firewall" "this_network_firewall" {

  name = var.firewall_name
  vpc_id = var.vpc_id
  firewall_policy_arn = aws_networkfirewall_firewall_policy.example.arn

  dynamic "subnet_mapping" {
    for_each = var.endpoint_subnets
    content {
      subnet_id = subnet_mapping.value
    }
  }

  tags = {
    Name = var.firewall_name
  }
}

resource "aws_networkfirewall_firewall_policy" "example" {

  name = var.firewall_policy_name

  firewall_policy {
    stateless_default_actions = var.stateless_default_actions
    stateless_fragment_default_actions = var.stateless_fragment_default_actions

    dynamic "stateless_rule_group_reference" {
      for_each = var.stateless_rule_groups
      iterator = rg
      content {
        priority = rg.value.priority
        resource_arn = rg.value.resource_arn
      }
    }
  }
}