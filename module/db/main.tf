resource "aws_db_instance" "db_instance_4_wordpress" {
  count                  = 3
  allocated_storage      = 20
  max_allocated_storage  = 100
  db_name                = "wordpress_db"
  engine                 = "mysql"
  engine_version         = "8.0.33"
  instance_class         = "db.t4g.micro"
  username               = "admin"
  password               = "valentinmotdepassesecurise11"
  storage_type           = "gp2"
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  identifier             = "wordpress-db-vbrison-${count.index}"
  db_subnet_group_name   = var.valentin_db_subnet
  vpc_security_group_ids = [var.database_sg_id]
}