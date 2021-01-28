provider "aws" {
  region = "us-east-2"
  access_key = "<access_key>"
  secret_key = "<access_secret>"
}

resource "aws_vpc" "main" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "Test cloud VPC"
  }
}

resource "aws_internet_gateway" "main" {
 vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "us-east-2a"
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "default" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.default.id
}

resource "aws_network_acl" "allowall" {
  vpc_id = aws_vpc.main.id

  egress {
    protocol = "-1"
    rule_no  = 100
    action   = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port   = 0
  }

  ingress {
    protocol = "-1"
    rule_no  = 200
    action   = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port   = 0
  }
}

resource "aws_security_group" "allowall" {
  name = "Terraform Crash Cource Allow All"
  description = "Allows all traffic which it should not do!"
  vpc_id = aws_vpc.main.id

  # opens port 22
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "derp" {
  instance = aws_instance.terraform-example.id
  vpc      = true
  depends_on = ["aws_internet_gateway.main"]
}

resource "aws_key_pair" "default" {
  key_name = "hw_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9D3RAApIbFi7P830RoJaJ+IJk4hfYsv68f7Ysm6Axzer85NL6Q4pkkiu4PRVx6CyvOJNAa2gUrFl6JKCzRUCPEf6E9i67ejqxeXTVKlHRzLRa1P9kbd3Ojahitj2HGg8T01g30T7apq+e5a7ozsaivMzf3Jl3TYUGX5z4B+RMEdYzG2y5MCWCqy1qNCqEl4c+e9+eyw4ox2LJVlvaAZ7E/AbN6ubhtTz7oXOfavH0HCiUD5RfDZX4h5bf61zieK03wD08YvlAghlVUkCv++GKIoFRuvN9MESnO5oyqMvCdySHDmlA3jiFPL2iRqeLYKF1oGIQJruZAZJV7GbZsNf29K21KcPWPwsqUBEuImub75DAXN8M4wMBEvUB+ushBCHFf3zYOxtHaRZG04Wfi18YGZn7gkqaHbnytu3eETSdjgLNOIWEnGXdA1vGR4BQ5wLhd6puxtWlVN9eZ6Ls9kseDMUdfZGfUSKJg+zSFF7nQPu+bIv7oHKc8xSFHTlrTJM= zfolwick@Zacharys-MBP"
}

resource "aws_instance" "terraform-example" {
  ami           = "ami-01aab85a5e4a5a0fe"
  instance_type = "t2.micro"
  tags = {
    Name = "terry_form"
  }
  key_name = aws_key_pair.default.key_name
  vpc_security_group_ids = [aws_security_group.allowall.id]
  subnet_id = aws_subnet.main.id
}
 
# prints out the public ip address. It appears "terraform apply" must be run twice for this to take affect.
output "public_ip" {
  value = aws_instance.terraform-example.public_ip
}
