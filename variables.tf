variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ami" {
  type = string
  default = "Amazon Linux 2023 AMI 2023.6.20250203.1 x86_64 HVM kernel-6.1"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}
