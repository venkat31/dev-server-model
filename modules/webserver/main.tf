resource "aws_security_group" "my_security_group" {
  vpc_id = var.vpc_id
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

data "aws_ami" "amazon_linux_image" {
  most_recent = true 
  owners = ["amazon"]
  filter {
    name = "name"
    values = [var.image]
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

  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.my_server_key.key_name

  user_data = file("entry_script_second.sh")

  tags = {
    Name = "${var.env_prefix}-server"
  }
}
