resource "aws_db_instance" "db_instance_4_wordpress" {
  count                  = 3
  allocated_storage      = 20
  max_allocated_storage  = 100
  db_name                = "wordpress_db"
  engine                 = "mysql"
  engine_version         = "8.0.33"
  instance_class         = "db.t2.micro"
  username               = "admin"
  password               = "valentinmotdepassesecurise11"
  storage_type           = "gp2"
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  identifier             = "wordpress-db-valentin-brison"
  db_subnet_group_name   = var.private_subnet[count.index]
  vpc_security_group_ids = [var.database_sg_id]
}