output "public_subnet" {
  value = aws_subnet.public_subnet.*.id
}

output "private_subnet" {
  value = aws_subnet.private_subnet.*.id
}

output "valentin_db_subnet" {
  value = aws_db_subnet_group.valentin_db_subnet.name
}
