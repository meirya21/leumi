module "compute" {
    source = "./modules/compute"
    depends_on = [module.network]
    single_target = var.single_target
    ami = var.ami
    instance_type = var.instance_type
    associate_public_ip_address = var.associate_public_ip_address
    key = var.key
    instance1 = var.instance1
    lb-name = var.lb-name
    instance_port = var.instance_port
    instance_protocol = var.instance_protocol
    lb_port = var.lb_port
    lb_protocol = var.lb_protocol
    Vpc-name = var.Vpc-name
    subnet1 = var.subnet1
}

module "network" {
    source = "./modules/network"
    single_target = var.single_target
    vpc_cider = var.vpc_cider
    subnet1_cidr = var.subnet1_cidr
    subnet1_az = var.subnet1_az
    Vpc-name = var.Vpc-name
    subnet1 = var.subnet1
}