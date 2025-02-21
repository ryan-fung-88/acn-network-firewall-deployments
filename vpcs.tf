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