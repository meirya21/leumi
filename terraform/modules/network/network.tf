resource "aws_vpc" "meir-terraform-vpc" {
    cidr_block = var.vpc_cider
    tags = {
      Name = var.Vpc-name
      owner = var.Owner
      created = timestamp()
    }
}

resource "aws_subnet" "meir-terraform-subnet1" {
    vpc_id = aws_vpc.meir-terraform-vpc.id
    cidr_block = var.subnet1_cidr
    availability_zone = var.subnet1_az

    tags = {
        Name = var.subnet1
        owner = var.Owner
        created = timestamp()
    } 
}

resource "aws_internet_gateway" "app-igw" {
    vpc_id = aws_vpc.meir-terraform-vpc.id

    tags = {
        Name = var.igw-name
        owner = var.Owner
        created = timestamp()
    }
}

resource "aws_route_table" "app-ige-route" {
    vpc_id = aws_vpc.meir-terraform-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.app-igw.id
    }

    tags = {
        Name = var.igw-route
        owner = var.Owner
        created = timestamp()
    }  
}

resource "aws_main_route_table_association" "app-igw-route" {
    vpc_id = aws_vpc.meir-terraform-vpc.id
    route_table_id = aws_route_table.app-ige-route.id
}