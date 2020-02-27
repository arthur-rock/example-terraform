# 0) Explain resource and data.
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# 1) VPC
resource "aws_vpc" "main" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name  = "primary-vpc"
    Owner = var.owner #Parametrize
  }
}

# 2) Subnet
resource "aws_subnet" "subnet_public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.16.1.0/24"
  #map_public_ip_on_launch = true #it makes this a public subnet
  availability_zone = "us-west-2a"
  tags = {
    Name  = "public-subnet"
    Owner = var.owner
  }
}

# 3) Internet Gateway: enable vpc to connect to the internet
# https://www.terraform.io/docs/providers/aws/r/internet_gateway.html
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name  = "igw"
    Owner = var.owner
  }
}

# 4) route table
# https://www.terraform.io/docs/providers/aws/r/route_table.html
resource "aws_route_table" "public_crt" {
  vpc_id = aws_vpc.main.id

  route {
    //associated subnet can reach everywhere
    cidr_block = "0.0.0.0/0"
    //CRT uses this IGW to reach internet
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name  = "public-crt"
    Owner = var.owner
  }
}

# 5)  route table association
resource "aws_route_table_association" "crta_public_subnet" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.public_crt.id
}

# 6) security group
resource "aws_security_group" "ssh" {
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # allowed for all :|
  }
  //For http  
  # ingress {
  #     from_port = 80
  #     to_port = 80
  #     protocol = "tcp"
  #     cidr_blocks = ["0.0.0.0/0"]
  # }
  # tags = {
  #   Name = "ssh-allowed"
  # }
}
#Only liste 22
resource "aws_instance" "nginx" {
  ami           = data.aws_ami.ubuntu.id # Ubuntu 18 bionic
  instance_type = "t2.nano"
  subnet_id     = aws_subnet.subnet_public.id
  # security group
  vpc_security_group_ids = [aws_security_group.ssh.id]
  # Using user_data
  #
  key_name = aws_key_pair.wargo.key_name
  tags = {
    Name = "Nginx"
  }

}

resource "aws_eip" "nginx" {
  instance = aws_instance.nginx.id
  vpc      = true
}

resource "aws_key_pair" "wargo" {
  key_name   = "wargo@popOs"
  public_key = var.wargo_key
}
