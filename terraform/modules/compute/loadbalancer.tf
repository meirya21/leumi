resource "aws_elb" "meir-app-lb" {
    name = var.lb-name
    subnets = [data.aws_subnet.subnet1.id]
    security_groups = [aws_security_group.loadbalancer_sg.id]
    listener {
      instance_port = 80
      instance_protocol = var.instance_protocol
      lb_port = 8080
      lb_protocol = var.lb_protocol
    }

    health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 30
    }

    instances = [aws_instance.instance1.id, length(aws_instance.instance2)]
    cross_zone_load_balancing = true

    tags = {
        Name = var.lb-name
        owner = var.Owner
        created = timestamp()
    }
}