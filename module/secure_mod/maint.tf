# load balancer security group
resource "aws_security_group" "aws_loadbalancer_sg" {
  name = "aws_loadbalancer_sg"
  tags = {
    Name = "aws_loadbalancer_sg"
  }
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "alb_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aws_loadbalancer_sg.id
}

resource "aws_security_group_rule" "alb_egress" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.aws_loadbalancer_sg.id
  source_security_group_id = aws_security_group.aws_loadbalancer_sg.id
}

# EC2/WordPress App Security Group
resource "aws_security_group" "ec2_wordpress_sg" {
  name = "ec2_wordpress_sg"
  tags = {
    Name = "ec2_wordpress_sg"
  }
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "ec2_ingress" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ec2_wordpress_sg.id
  source_security_group_id = aws_security_group.aws_loadbalancer_sg.id
}

resource "aws_security_group_rule" "ec2_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_wordpress_sg.id
}

# RDS/Database Security Group
resource "aws_security_group" "database_sg" {
  name = "database_sg"
  tags = {
    Name = "database_sg"
  }
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "rds_ingress" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.database_sg.id
  source_security_group_id = aws_security_group.ec2_wordpress_sg.id
}