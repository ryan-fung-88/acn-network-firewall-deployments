variable "create_tgw" {
  type = bool
  description = "Provsion Transit Gateway resource"
}

variable "auto_accept_shared_attachments" {
  type = string
  default = "disable"
  description = "Whether resource attachment requests are automatically accepted"
}

variable "default_route_table_association" {
  type = string
  default = "enable"
  description = "Whether resource attachment requests are automatically accepted"
}

variable "default_route_table_propagation" {
  type = string
  default = "enable"
  description = "Whether resource attachments automatically propagate routes to the default propagation route table"
}

variable "tgw_description" {
  type = string
  default = ""
  description = "Descrirption of Target Gateway resource"
}

variable "vpc_attachments" {
  type = map(object({
    vpc_id = string
    subnet_ids= list(strings)
    dns_support = string
    transit_gateway_default_route_table_association = bool
    transit_gateway_default_route_table_propagation = bool
  }))
  default = {}
}