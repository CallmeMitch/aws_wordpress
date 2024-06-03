# Create a VPC
resource "aws_vpc" "val_vpc" {
  cidr_block = "10.0.0.0/16"
}

module "network" {
    source = "./modules/network"
    vpc_id = aws_vpc.val_vpc.id
}