variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ami" {
  type = string
  default = "ami-053a45fff0a704a47"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}
