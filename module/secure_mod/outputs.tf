output "database_sg_id" {
  value = aws_security_group.database_sg.id
}

output "aws_loadbalancer_sg_id" {
  value = aws_security_group.aws_loadbalancer_sg.id
}