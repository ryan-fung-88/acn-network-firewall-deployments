variable "firewall_name" {
  type = string
  description = "Name of Network firewall"
}

variable "vpc_id" {
  type = string
  description = "ID of VPC to associate network firewall with"
}

variable "endpoint_subnets" {
  type = list(string)
  default = []
  description = "List of subnets to deploy network firewall endpoint"
}

variable "firewall_policy_name" {
  type = string
  description = "Name of network firewall policy"
}

variable "stateless_default_actions" {
  type = list(string)
  description = "Set of actions to take on a packet if it does not match any of the stateless rules in the policy. You must specify one of the standard actions including: aws:drop, aws:pass, or aws:forward_to_sfe."
}

variable "stateless_fragment_default_actions" {
  type = list(string)
  description = "Set of actions to take on a fragmented packet if it does not match any of the stateless rules in the policy. You must specify one of the standard actions including: aws:drop, aws:pass, or aws:forward_to_sfe."
}

variable "stateless_rule_groups" {
  type = map(object({
    priority = number
    resource_arn = string 
  }))
  description = " Set of configuration blocks containing references to the stateful rule groups that are used in the policy."
}