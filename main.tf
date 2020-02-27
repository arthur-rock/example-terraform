
resource "aws_vpc" "main" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name  = "primary_vpc"
    Owner = var.owner #Parametrize
  }
}

resource "aws_subnet" "subnet" {
  vpc_id     = "${aws_vpc.my_vpc.id}"
  cidr_block = "172.16.10.0/24"

  tags = {
    Name  = "primary_subnet"
    Owner = var.owner
  }

}

resource "aws_network_interface" "interface" {
  subnet_id   = "${aws_subnet.my_subnet.id}"
  private_ips = ["172.16.10.100"]

  tags = {
    Name  = "primary_network_interface"
    Owner = var.owner
  }
}


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


resource "aws_instance" "web" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"


  network_interface {
    network_interface_id = aws_network_interface.interface.id
    device_index         = 0
  }

  tags = {
    Name  = "test_instance"
    Owner = var.owner
  }
}

