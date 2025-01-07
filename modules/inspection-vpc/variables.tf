
variable "cidr" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "instance_tenancy" {
  type = string
  default = "default"
  description = "A tenancy option for instances launched into the VPC"
}

variable "enable_dns_support" {
  type = bool
  default = true
  description = "enable/disable DNS support in the VPC"
}

variable "enable_dns_hostnames" {
  type = bool
  default = false
  description = "enable/disable DNS hostnames in the VPC"
}

variable "vpc_tags" {
  type = map(string)
  default = {}
}

variable "public_subnets" {
    type = list(string)
    default = []
}

variable "private_subnets" {
    type = list(string)
    default = []
}

variable "avalibility_zones" {
  type = list(string)
  default = []
}

variable "enable_public_dns64" {
    type = bool
    default = false
  
}

variable "map_public_ip_on_launch" {
  type = bool
  default = false
}

variable "enable_private_dns64" {
  type = bool
  default = false
}

variable "private_dns_hostname_type_on_launch" {
  type = string
  default = "ip-name"
}

variable "multiple_public_route_tables" {
  type = bool
  default = false
}

variable "multiple_private_route_tables" {
  type = bool
  default = false
}

variable "destination_cidr_block" {
  type = string
  default = "0.0.0.0/0"
}

variable "transit_gateway_id" {
  type = string
}

variable "vpc_endpoint_id" {
  type = string
}