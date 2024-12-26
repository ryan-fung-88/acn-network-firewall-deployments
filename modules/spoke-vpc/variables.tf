variable "region" {
  type = string
  default = "us-east-1"
}
variable "cidr" {
  type = string
  default = "10.0.0.0/16"
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