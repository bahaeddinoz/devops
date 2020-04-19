# define s3 bucket for using state file of terraform
terraform {
  backend "s3" {
    bucket = "terraform-state.devops.bahaddinozcelik.com"
    key    = "file-state"
    region = "eu-west-2"
  }
}
# define aws region
provider "aws" {
  region = "eu-west-2"
}
# define varible for block_cidr
variable "vpc_cidr_block" {default = "10.0.0.0/16"}
# we will define project_name, domain as global enviroment and use parameter
variable "project_name" {}
variable "domain" {}
# define network variable to give for subnets
variable "networks" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = {
    n0 = {
      cidr_block        = "10.0.0.0/24"
      availability_zone = "eu-west-2a"
    }
    n1 = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "eu-west-2b"
    }
  }
}

# define aws resource with vpc_cidr_block, and project_name variable 
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "Name" = var.project_name
  }
}

# first time we create it
#resource "aws_route53_zone" "domain" {
#  name = var.domain
#}

# getting data for outputs
data "aws_availability_zones" "available" {}

# define aws subnets with networks variable
resource "aws_subnet" "subnets" {
  count = length(var.networks)
  availability_zone = var.networks["n${count.index}"].availability_zone
  cidr_block        = var.networks["n${count.index}"].cidr_block
  vpc_id            = aws_vpc.vpc.id
  tags = {
    "Name" = var.project_name
  }
}
# define gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}
 # define route table to reach 0.0.0.0/0 with gateway
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = var.project_name
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}
# define route table association
resource "aws_route_table_association" "route_table_association" {
  count = length(var.networks)
  subnet_id     = aws_subnet.subnets.*.id[count.index]
  route_table_id = aws_route_table.route_table.id
}
# get vpc_ids for terraform output
output "vpc_id" {
  value = aws_vpc.vpc.id
}

# reach ids of subnets for terraform output
data "aws_subnet_ids" "subnet_ids" {
  depends_on = [
    aws_subnet.subnets
  ]
  vpc_id = aws_vpc.vpc.id
}

# get ids of subnets for terraform output
output "subnet_ids" {
  value = data.aws_subnet_ids.subnet_ids.ids.*
}

# get networks for terraform output
output "networks" {
  value = var.networks
}
