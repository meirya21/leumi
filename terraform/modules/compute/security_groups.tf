resource "aws_security_group" "instance" {
    name = var.instance-sg
    description = "AWS sg for app instance"
    vpc_id = data.aws_vpc.meir-terraform-vpc.id

    ingress {
        description = "Allow port 8080 from loadbalancer security group"
        from_port = 8080
        to_port = 80
        protocol = var.lb_protocol
        security_groups = [aws_security_group.loadbalancer_sg.id]
    }

    ingress {
        description = "Allow SSH from jump_server_sg"
        from_port = 22
        to_port = 22
        protocol = var.lb_protocol
        cidr_blocks = ["91.231.246.50"]
    }  

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        Name = var.instance-sg
        owner = var.Owner
        created = timestamp()
    }
}

resource "aws_security_group" "loadbalancer_sg" {
    name = var.lb-sg
    description = "Allow HTTP inbound traffic to loadbalancer"
    vpc_id = data.aws_vpc.meir-terraform-vpc.id

    ingress {
        description = "HTTP from vpc"
        from_port = 8080
        to_port = 80
        protocol = var.instance_protocol
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        Name = var.lb-sg
        owner = var.Owner
        created = timestamp()
    }
}