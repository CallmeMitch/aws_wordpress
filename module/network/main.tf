## Création des subnets


## Public subnet avec un count pour les 3 AZs
resource "aws_subnet" "public_subnet" {
  count                   = 3
  vpc_id                  = var.vpc_id
  
  cidr_block              = cidrsubnet(var.public_subnet_cidr.cidr_block, 8, count.index)
  
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
  cidr_block              = cidrsubnet(var.private_subnet_cidr_wordpress.cidr_block, 8, count.index)
  availability_zone       = element(var.azs, count.index)
  depends_on              = [var.aws_vpc]
  tags = {
    Name = "private-subnet-${count.index}"
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

## Internet Gateway création 
resource "aws_internet_gateway" "val-gw-Internet" {
  vpc_id = var.vpc_id
}

## Déclaration d'une nat gateway
resource "aws_nat_gateway" "val-nat-gw" {
  count = 3
  allocation_id = aws_eip.val-eip.id
  subnet_id     = aws_subnet.public_subnet[count.index].id
  depends_on = [aws_eip.val-eip, aws_subnet.public_subnets[count.index]]
  connectivity_type = "public"

  tags = {
    Name = "${var.azs[count.index]}- nat gateway"
  }
}

## Déclaration de l'EIP 
resource "aws_eip" "val-eip" {
#  count = 3
  domain                    = "vpc"
  network_interface         = aws_network_interface.val-network-interface.id
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
    gateway_id = aws_internet_gateway.val-gw-Internet[count.index].id
  }
  tags = {
    Name = "Route table for public subnet"
  }
}

# Private Route Tables

resource "aws_route_table" "route_table_private_subnet" {
  count = 3
  depends_on = [aws_nat_gateway.val-nat-gw[count.index]]
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
  subnet_id      = element(aws_subnet.public_subnet[*].id, [count.index])
  route_table_id = aws_route_table.route_table_public_subnet.id
}
# Association pour le private subnet
resource "aws_route_table_association" "rivate_subnet_association" {
  subnet_id      = element(aws_subnet.private_subnet[*].id, [count.index])
  route_table_id = aws_route_table.route_table_private_subnet.id
}
