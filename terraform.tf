# Create a VPC
resource "aws_vpc" "val_vpc" {
  cidr_block = "10.0.0.0/16"
}

module "network" {
    source              = "./module/network"
    vpc_id              = aws_vpc.val_vpc.id
    aws_vpc_cidr        = aws_vpc.val_vpc.cidr_block
    aws_vpc             = aws_vpc.val_vpc
}

module "db" {
    source            = "./module/db"
    database_sg_id    = module.secure_mod.database_sg_id
    valentin_db_subnet = module.network.valentin_db_subnet
}

module "secure_mod" {
  source = "./module/secure_mod"
  vpc_id = aws_vpc.val_vpc.id
}

module "lb" {
  source = "./module/lb"
  aws_loadbalancer_sg_id = module.secure_mod.aws_loadbalancer_sg_id
  public_subnet = module.network.public_subnet
  private_subnet = module.network.private_subnet
  vpc_id = aws_vpc.val_vpc.id
  autoscaling_group_name = module.wordpress.autoscaling_group_name
}

module "wordpress" {
  source = "./module/wordpress"
  aws_db_instance = module.db.aws_db_instance
  private_subnet = module.network.private_subnet
}