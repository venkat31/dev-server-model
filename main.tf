provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr_blocks[0].cidr_block
  tags = {
    Name : var.cidr_blocks[0].name
    vpc_env : var.environment
  }
}

variable avail_zone {

}

variable "cidr_blocks" {
  
  type = list(object({
    name = string
    cidr_block = string

    }))
}

variable "environment" {
  description = "deployment environment"
  default = "development"
}

resource "aws_subnet" "my_subnet"{
  vpc_id = aws_vpc.my_vpc.id 
  cidr_block = var.cidr_blocks[1].cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = var.cidr_blocks[1].name
  }
}

data "aws_vpc" "my-default-vpc" {
  default = true
}

# resource "aws_subnet" "my-dev-subnet2"{
#   vpc_id = data.aws_vpc.my-default-vpc.id
#   cidr_block = "172.31.96.0/20"
#   availability_zone = "var.avail_zone"
#   tags = {
#     Name: "default-vpc"
#   }

# }

output "dev-vpc-id" {
  value = aws_vpc.my_vpc.id
}

