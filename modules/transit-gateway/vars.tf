variable "create_tgw" {
  type = bool
  description = "Provsion Transit Gateway resource"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
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
    subnet_ids= list(string)
    dns_support = string
    transit_gateway_default_route_table_association = bool
    transit_gateway_default_route_table_propagation = bool
  }))
  default = {}
}

variable "transit_gateway_route_table_id" {
  description = "Identifier of EC2 Transit Gateway Route Table to use with the Target Gateway when reusing it between multiple TGWs"
  type        = string
  default     = null
}

variable "create_tgw_routes" {
  description = "Controls if TGW Route Table / Routes should be created"
  type        = bool
  default     = true
}

variable "tgw_route_table_tags" {
  description = "Additional tags for the TGW route table"
  type        = map(string)
  default     = {}
}

variable "tgw_default_route_table_tags" {
  description = "Additional tags for the Default TGW route table"
  type        = map(string)
  default     = {}
}