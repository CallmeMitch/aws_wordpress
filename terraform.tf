# Create a VPC
resource "aws_vpc" "val_vpc" {
  cidr_block = "10.0.0.0/16"
}

module "network" {
    source = "./module/network"
    vpc_id = aws_vpc.val_vpc.id
    aws_vpc_cidr = aws_vpc.val_vpc.cidr_block
    aws_vpc = aws_vpc.val_vpc
}