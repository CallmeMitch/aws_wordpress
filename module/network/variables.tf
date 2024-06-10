variable "vpc_id" {
}

variable "aws_vpc" {
}

variable "aws_vpc_cidr" {
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}
