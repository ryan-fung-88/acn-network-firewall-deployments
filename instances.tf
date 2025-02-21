module "vpc_a_sg_ssh" {
  source = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "5.1.0"

  name        = "SSH-SG-VPC-A"
  description = "Security group for ssh  within VPC"
  vpc_id      = module.spoke-vpc-a.vpc_id

  ingress_cidr_blocks = [module.spoke-vpc-a.vpc_cidr_block, module.spoke-vpc-b.vpc_cidr_block]
}

module "vpc_a_sg_https" {
  source = "terraform-aws-modules/security-group/aws//modules/https-443"
  version = "5.1.0"

  name        = "HTTPS-SG-VPC-A"
  description = "Security group for https  within VPC"
  vpc_id      = module.spoke-vpc-a.vpc_id

  ingress_cidr_blocks = [module.spoke-vpc-a.vpc_cidr_block, module.spoke-vpc-b.vpc_cidr_block]
}

module "vpc_b_sg_ssh" {

  source = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "5.1.0"

  name        = "SSH-SG-VPC-B"
  description = "Security group for ssh  within VPC"
  vpc_id      = module.spoke-vpc-b.vpc_id

  ingress_cidr_blocks = [module.spoke-vpc-a.vpc_cidr_block, module.spoke-vpc-b.vpc_cidr_block]
}

module "vpc_b_sg_https" {

  source = "terraform-aws-modules/security-group/aws//modules/https-443"
   version = "5.1.0"

  name        = "HTTPS-SG-VPC-B"
  description = "Security group for https  within VPC"
  vpc_id      = module.spoke-vpc-b.vpc_id

  ingress_cidr_blocks = [module.spoke-vpc-a.vpc_cidr_block, module.spoke-vpc-b.vpc_cidr_block,]
}

resource "aws_instance" "spoke_a_instance" {

    ami = var.ami
    instance_type = var.instance_type
    vpc_security_group_ids = [module.vpc_a_sg_ssh.security_group_id,module.vpc_a_sg_https.security_group_id]
    subnet_id = module.spoke-vpc-a.public_subnets[0]
    iam_instance_profile = aws_iam_instance_profile.test_profile.name
    user_data = <<EOF
    #!/bin/bash
    sleep 60;
    yum install  -y
    sleep 5;
    yum install nc telnet -y
    EOF
    tags = {
      Name = "test-vpc-a"
    }
}

resource "aws_instance" "spoke_b_instance" {

    ami = var.ami
    instance_type = var.instance_type
    vpc_security_group_ids = [module.vpc_b_sg_ssh.security_group_id,module.vpc_b_sg_https.security_group_id]
    subnet_id = module.spoke-vpc-b.public_subnets[0]
    iam_instance_profile = aws_iam_instance_profile.test_profile.name
    user_data = <<EOF
    #!/bin/bash
    sleep 60;
    yum install  -y
    sleep 5;
    yum install nc telnet -y
    EOF
    tags = {
      Name = "test-vpc-b"
    }
}