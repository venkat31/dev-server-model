provider "aws"{

}

variable vpc_cidr_block {

}
variable subnet_cidr_block {

}

variable avail_zone {}
variable env_prefix{}
variable my_ip{}
variable instance_type {}
variable public_key_location {}

resource "aws_vpc" "myapp-vpc"{
  cidr_block = var.vpc_cidr_block 
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }

}

# resource "aws_route_table" "my-route-table"{
#   vpc_id = aws_vpc.myapp-vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.my_igw.id
#   }
#   tags = {
#     Name = "${var.env_prefix}-routetable"
#   }
# }

resource "aws_default_route_table" "my_rtb"{
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "${var.env_prefix}-main-routetable"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id =  aws_vpc.myapp-vpc.id
  tags = {
    Name = "${var.env_prefix}-igateway"
  }
}

resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.myapp-vpc.id
  name = "myapp_security_group"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name = "${var.env_prefix}-sg"
  }
}
# resource "aws_route_table_association" "a-rtb" {
#   subnet_id = aws_subnet.myapp-subnet-1.id
#   route_table_id = aws_route_table.my-route-table.id
# }
# resource "aws_instance" "myapp-server" {
#   ami_id = 
# }

data "aws_ami" "amazon_linux_image" {
  most_recent = true 
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "my_server_key"{
  key_name = "own_ssh_key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "myapp-server"{
  ami = data.aws_ami.amazon_linux_image.id 
  instance_type = var.instance_type

  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.my_server_key.key_name

  user_data = file("entry_script_second.sh")

  tags = {
    Name = "${var.env_prefix}-server"
  }

}
