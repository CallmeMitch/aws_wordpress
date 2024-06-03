## Création des subnets

## Public subnet AZ1
resource "aws_subnet" "public_subnet" {
  vpc_id     = var.vpc_id
  cidr_block = "10.0.1.0/24"
}

## Private subnet AZ1
resource "aws_subnet" "private_subnet" {
  vpc_id     = var.vpc_id
  cidr_block = "10.0.10.0/24"
}

## Déclaration de la Route Table
resource "aws_route_table" "val-route-table" {
  vpc_id = var.vpc_id


###  Il s'agit d'une manière de créer une route.
  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.val-gw-Internet.id
  }
}

## Create Network interface
resource "aws_network_interface" "val-network-interface" {
  subnet_id       = aws_subnet.public_subnet.id
  private_ips     = ["10.0.0.50"]
  security_groups = [aws_security_group.web.id]

  attachment {
    instance     = aws_instance.test.id
    device_index = 1
  }
}


### Second moyen de créer une route. 

## Déclaration de la route AWS
resource "aws_route" "valentin-route" {
  route_table_id            = aws_route_table.val-route-table.id
  destination_cidr_block    = "10.0.1.0/22"
  vpc_peering_connection_id = "pcx-45ff3dc1"
}

## Déclaration de l'EIP 
resource "aws_eip" "val-eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.val-network-interface.id
  associate_with_private_ip = "10.0.0.10"
}

## Internet Gateway
resource "aws_internet_gateway" "val-gw-Internet" {
  vpc_id = var.vpc_id
}

## Déclaration d'une nat gateway
resource "aws_nat_gateway" "val-nat-gw" {
  allocation_id = aws_eip.val-eip.id
  subnet_id     = aws_subnet.public_subnet.id
  depends_on = [aws_internet_gateway.val-gw-Internet]
}