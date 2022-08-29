variable "ami" {
    type = string
    default = "ami-00c90dbdc12232b58"
}

variable "instance_type" {
    type = string
    default = "t2.micro"  
}

variable "key" {
    type = string
    default = "meirkey"
}

variable "Owner" {
    type = string
    default = "meir"
}

variable "lb_protocol" {
    type = string
    default = "tcp"
}

variable "instance_protocol" {
    type = string
    default = "tcp"
}

variable "lb-name" {
    type = string
    default = "meir-app-lb"
}

variable "Vpc-name" {
      type = string
      default = "meir-terraform-vpc"
}

variable "subnet1" {
    type = string
    default = "meir-terraform-subnet1"  
}

variable "instance1" {
    type = string
    default = "instance1"  
}

variable "igw-name" {
    type = string
    default = "meir-app-igw"  
}

variable "igw-route" {
    type = string
    default = "app-igw-route"  
}

variable "lb-sg" {
    type = string
    default = "app-lb-sg"  
}

variable "instance-sg" {
    type = string
    default = "app-instance-sg"  
}

variable  "associate_public_ip_address" {
    type    = bool
    default = true
}

variable  "subnet1_az" {
    type    = string
    default = "eu-west-1a"
}

variable "instance_port" {
    type = number
    default = 80
}

variable "lb_port" {
    type = number
    default = 8080
}

variable  "vpc_cider" {
    type    = string
    default = "10.0.0.0/16"
}

variable  "subnet1_cidr" {
    type    = string
    default = "10.0.0.0/28"
}

variable  "single_target" {
    type    = bool
    default = false
}