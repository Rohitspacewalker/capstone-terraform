resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "SL-VPC"
  }
}


#Internet Gateway 
resource "aws_internet_gateway" "IGW" {    
    vpc_id      =  aws_vpc.vpc.id   
      tags  = {
          Name = "SL-IGW"
          }
}   


# Public Subnet
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = var.public_azs[count.index]
  map_public_ip_on_launch = true
        tags = {
          Name = "SL-PUB-SUB-${count.index+1}"
        }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  count                    = length(var.private_subnet_cidr)
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.private_subnet_cidr[count.index]
  availability_zone        = var.private_azs[count.index]
  map_public_ip_on_launch  = false
  tags = {
    Name = "SL-PRIV-SUB-${count.index+1}"
  }
}

# Creating RT for Public Subnet and attach internet gateway
resource "aws_route_table" "PublicRT" {    
    vpc_id             =  aws_vpc.vpc.id
          route {
            cidr_block = "0.0.0.0/0"                
            gateway_id = aws_internet_gateway.IGW.id
        }
        tags = {
            Name = "SL-publicsubnetRT"
        }
}

# Route table association with public subnets
resource "aws_route_table_association" "pub-sub-asso" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
  route_table_id = aws_route_table.PublicRT.id
}
# Allocate Elastic IP
 resource "aws_eip" "eip1" {
        vpc      = true
        tags = {
            Name = "TF-pub-subnet-1"
        }
}
 
 resource "aws_eip" "eip2" {
        vpc      = true
         tags = {
            Name = "TF-pub-subnet-2"
        }
}



resource "aws_nat_gateway" "Nat-GW1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "SL-natgw-01"
  }

  depends_on = [aws_internet_gateway.IGW]
}

resource "aws_nat_gateway" "Nat-GW2" {
  allocation_id = aws_eip.eip2.id
  subnet_id     = aws_subnet.public_subnet[1].id

  tags = {
    Name = "SL-natgw-02"
  }

  depends_on = [aws_internet_gateway.IGW]
}

# Creating RT for Private Subnet and attach NAT gateway
resource "aws_route_table" "PrivateRT1" {    
    vpc_id             =  aws_vpc.vpc.id
          route {
            cidr_block = "0.0.0.0/0"                
            nat_gateway_id = aws_nat_gateway.Nat-GW1.id
        }
        tags = {
            Name = "SL-privatesubnetRT-01"
        }
}

 resource "aws_route_table" "PrivateRT2" {    
    vpc_id             =  aws_vpc.vpc.id
          route {
            cidr_block = "0.0.0.0/0"                
            nat_gateway_id = aws_nat_gateway.Nat-GW2.id
        }
         tags = {
            Name = "SL-RT-privatesubnetRT-02"
        }
}

resource "aws_security_group" "SG1" {
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.vpc.id
     tags = {
    Name = "TF-alb-sg"
  }
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "all"
    cidr_blocks      = ["0.0.0.0/0"]

}
}

resource "aws_security_group" "SG" {
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.vpc.id
     tags = {
    Name = "TF-sg"
  }
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "all"
    cidr_blocks      = ["0.0.0.0/0"]
}

egress {
    from_port        = 0
    to_port          = 0
    protocol         = "all"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

