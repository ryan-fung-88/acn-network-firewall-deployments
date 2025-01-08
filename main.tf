module "spoke-vpc" {
  source = "./modules/spoke-vpc"
  
  vpc_name = "spoke-vpc-a"
  cidr = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  avalibility_zones = ["${var.region}a", "${var.region}b"]
  multiple_public_route_tables = true
  multiple_private_route_tables = false
}
