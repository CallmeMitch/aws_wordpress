variable "vpc_id" {
}

variable "aws_vpc" {
}

variable "aws_vpc_cidr" {
}
###  Variable about sub-network


#variable "aws_network_interface_private_ips" {
#}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

#variable "public_subnet_cidr" {
#  type        = list(string)
#  description = "Public Subnet CIDR Values"
#  default     = ["10.0.1.0/24"]
#}

#variable "private_subnet_cidr_wordpress" {
#  type        = list(string)
#  description = "Public Subnet CIDR Values"
#  default     = ["10.0.10.0/24"]
#}