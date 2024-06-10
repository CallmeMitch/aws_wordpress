## Création des subnets


## Public subnet avec un count pour les 3 AZs
resource "aws_subnet" "public_subnet" {
  count                   = 3
  vpc_id                  = var.vpc_id
  
  cidr_block              = cidrsubnet(var.aws_vpc_cidr, 8, count.index)
  
  availability_zone       = element(var.azs, count.index)
  
  depends_on = [ var.aws_vpc ]
  
  tags = {
    Name = "public-subnet-${count.index}"
  }
}

## Private subnet avec un count pour les 3 AZs.
resource "aws_subnet" "private_subnet" {
  count                   = 3
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(var.aws_vpc_cidr, 8, count.index +10)
  availability_zone       = element(var.azs, count.index)
  depends_on              = [var.aws_vpc]
  tags = {
    Name = "private-subnet-${count.index}"
  }
}


## Create Network interface
resource "aws_network_interface" "val-network-interface" {
  count           = 3
  subnet_id       = aws_subnet.public_subnet[count.index].id
  private_ips     = [var.aws_vpc_cidr, 8, count.index + 20]
  #security_groups = [aws_security_group.web.id]

#  attachment {
#    instance     = aws_instance.test.id
#    device_index = 1
#  }
}

## Internet Gateway création 
resource "aws_internet_gateway" "val-gw-Internet" {
  vpc_id = var.vpc_id
}

## Déclaration des nat gateway
resource "aws_nat_gateway" "val-nat-gw" {
  count             = 3
  allocation_id     = aws_eip.val-eip[count.index].id
  subnet_id         = aws_subnet.public_subnet[count.index].id
  depends_on        = [aws_eip.val-eip, aws_subnet.public_subnet[0], aws_subnet.public_subnet[1], aws_subnet.public_subnet[2]]
  connectivity_type = "public"

  tags = {
    Name = "${var.azs[count.index]}- nat gateway"
  }
}

## Déclaration de l'EIP 
resource "aws_eip" "val-eip" {
  count = 3
  domain                    = "vpc"
  network_interface         = aws_network_interface.val-network-interface[count.index].id
#  associate_with_private_ip = "10.0.0.10"

  tags = {
    Name = "WordPress - Nat_GateWay_EIP"
  }
}

#  destination_cidr_block    = "10.0.1.0/22"
#  vpc_peering_connection_id = "pcx-45ff3dc1"


# Public Route Table
resource "aws_route_table" "route_table_public_subnet" {
  depends_on = [aws_internet_gateway.val-gw-Internet]
  vpc_id     = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.val-gw-Internet.id
  }
  tags = {
    Name = "Route table for public subnet"
  }
}

# Private Route Tables

resource "aws_route_table" "route_table_private_subnet" {
  count = 3
  depends_on = [aws_nat_gateway.val-nat-gw[0], aws_nat_gateway.val-nat-gw[1], aws_nat_gateway.val-nat-gw[2]]
  vpc_id     = var.vpc_id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.val-nat-gw[count.index].id
  }

  tags = {
    Name = "${var.azs[count.index]} Private Route Table"
  }
}

# Association pour le public subnets
resource "aws_route_table_association" "public_subnet_association" {
  count          = 3
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.route_table_public_subnet.id
}
# Association pour le private subnet
resource "aws_route_table_association" "rivate_subnet_association" {
  count = 3
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.route_table_private_subnet[count.index].id
}

## subnet_id      = element(aws_subnet.private_subnet[*].id, [count.index])