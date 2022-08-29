data "aws_vpc" "meir-terraform-vpc" {
    filter {
        name = "tag:Name"
        values = [var.Vpc-name]
    }
}

data "aws_subnet" "subnet1" {
    filter {
        name = "tag:Name"
        values = [var.subnet1]
    }
}