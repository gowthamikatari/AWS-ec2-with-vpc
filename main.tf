resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
 tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
   tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
   tags = {
    Name = "private_subnet"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

 route {
    cidr_block  = "0.0.0.0/0"
    gateway_id  = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "route-table"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_instance" "terraform-server" {
  ami                     = "ami-04e5276ebb8451442"
  instance_type           = "t2.micro"
  key_name                    = "key_pair"
   subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  user_data = <<-EOF
    #!/bin/bash

    # Update the package list
    sudo apt update

    # Install Apache
    sudo apt install -y apache2
    sudo cat <<HTML > /var/www/html/index.html
    <!DOCTYPE html>
    <html><body><h1>Welcome to my website</h1></body></html>
    HTML

    sudo systemctl restart apache2
  EOF
 tags = {
    Name = "terraform-server"
  }
}

resource "aws_security_group" "ssh_access" {
   name_prefix = "ssh_access"
   vpc_id = aws_vpc.main.id
   ingress {
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
 }
   egress {
     from_port   = 0
     to_port     = 0
     protocol    = -1
     cidr_blocks = ["0.0.0.0/0"]
 }
 }

  resource "aws_eip" "ip" {
   instance = aws_instance.web_server.id
   vpc      = true
   tags = {
     Name = "elastic-ip"
   }
 }
