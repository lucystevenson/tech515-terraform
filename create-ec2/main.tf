# if you specify json you don't have to do chomp below

data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/" #"https://api.ipify.org?format=json" "https://api.ipify.org"
}

locals {
    my_ip_cidrblock = ["${chomp(data.http.my_ip.response_body)}/32"] #my_ip_cidrblock["${chomp(data.http.my_ip.response_body)}/32"] jsondecode(data.http.my_ip.response_body).ip
}


# db resource
# create AWS DB security group

resource "aws_security_group" "tech515_db_sg" {
    # ... other configuration ...
    name = var.db_sg_name
    description = var.db_sg_description
    vpc_id = aws_vpc.custom_vpc.id

    ingress {
        description = "MongoDB port 27017 from app sg"
        from_port   = 27017
        to_port     = 27017
        protocol    = "tcp"
        security_groups = [aws_security_group.tech515_app_sg.id]
    }

    # Allow all outbound traffic
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }
}

# create AWS DB instance
resource "aws_instance" "db_instance" {

    # SUBNET
    subnet_id = aws_subnet.subnet_2.id
    # which AMI ID ami-0c1c30571d2dae5c9 (for ubuntu 22.04 lts)
    ami = var.db_ami_id
 
    # what type of instance to launch
    instance_type = var.db_instance_type
 
    # please add a public ip to this instance
    associate_public_ip_address = false

    # Attach the security group to your EC2 instance:
    vpc_security_group_ids = [aws_security_group.tech515_db_sg.id]   

    # Add public key we made already
    key_name = var.db_public_key_name
    
    # If we want to add public key we made above
    # key_name = aws_key_pair.lucy_key.key_name
 
    # name the service
    tags = {
        Name = var.db_instance_tag_name # what you want it to be called when it's actually made
        Environment = "test"
    }
}

# create AWS security group

resource "aws_security_group" "tech515_app_sg" {

    # ... other configuration ...
    name = var.app_sg_name
    description = var.app_sg_description
    vpc_id = aws_vpc.custom_vpc.id


    # Allow port 3000 from all
    ingress {
        description = "app port 3000 from anywhere"
        from_port   = var.default_app_port
        to_port     = var.default_app_port
        protocol    = "tcp"
        cidr_blocks = var.app_sg_port_app_cidr_blocks
    }

    # Allow port 80 from all
    ingress {
        description = "HTTP port 80 from anywhere"
        from_port   = var.default_http_port
        to_port     = var.default_http_port
        protocol    = "tcp"
        cidr_blocks = var.app_sg_port_http_cidr_blocks
    }

    ingress {
        description = "SSH from my IP"
        from_port   = var.default_ssh_port
        to_port     = var.default_ssh_port
        protocol    = "tcp"
        cidr_blocks = local.my_ip_cidrblock # ["${chomp(data.http.my_ip.response_body)}/32"]
    }

    # Allow all outbound traffic
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = var.app_sg_port_0_cidr_blocks
        ipv6_cidr_blocks = var.app_sg_port_0_ipv6_cidr_blocks
    }

    # name the service
    tags = {
        Name = var.app_sg_tag_name # what you want it to be called when it's actually made
    }
}


# create an EC2 instance
# cloud provider is AWS
 
provider "aws" {
    # use Ireland region
    region = var.default_region
}
 
# which service/resource
resource "aws_instance" "app_instance" {
    depends_on = []
    # SUBNETS
    subnet_id = aws_subnet.subnet_1.id
 
    # which AMI ID ami-0c1c30571d2dae5c9 (for ubuntu 22.04 lts)
    ami = var.app_ami_id
 
    # what type of instance to launch
    instance_type = var.app_instance_type
 
    # please add a public ip to this instance
    associate_public_ip_address = true

    # Attach the security group to your EC2 instance:
    vpc_security_group_ids = [aws_security_group.tech515_app_sg.id]   

    # Add public key we made already
    key_name = var.public_key_name
    
    # If we want to add public key we made above
    # key_name = aws_key_pair.lucy_key.key_name
 
    # name the service
    tags = {
        Name = var.app_instance_tag_name # what you want it to be called when it's actually made
        Environment = "test"
    }
 
    user_data = <<-EOF
    #!/bin/bash
    echo "Running user data..."
    cd /home/ubuntu/tech515-sparta-app/app
    echo "export DB_HOST=mongodb://${aws_instance.db_instance.private_ip}:27017/posts" >> /etc/profile
    echo "export DB_HOST=mongodb://${aws_instance.db_instance.private_ip}:27017/posts" >> /home/ubuntu/.bashrc
    export DB_HOST="mongodb://${aws_instance.db_instance.private_ip}:27017/posts"
    echo "DB_HOST is: $DB_HOST"
    pm2 start app.js --update-env
    echo "User data done!"
    EOF
}


# VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block           = "10.0.0.0/16" 
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "tech515-lucy-custom-vpc"
  }
}

# SUBNETS

# PUBLIC
resource "aws_subnet" "subnet_1" {

  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = "10.0.2.0/24"    
 # availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "tech515-lucy-vpc-public-subnet-1"
  }
}

# PRIVATE
resource "aws_subnet" "subnet_2" {
  depends_on = [
  aws_vpc.custom_vpc
  ]

  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = "10.0.3.0/24"  
 # availability_zone = "eu-west-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "tech515-vpc-lucy-private-subnet-2"
  }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "tech515-lucy-vpc-ig"
  }
}

# ROUTE TABLES
resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "tech515-lucy-public-rt"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "tech515-lucy-private-rt"
  }
}

# ASSOCIATE PUBLIC SUBNET WITH RT

resource "aws_route_table_association" "subnet_1_assoc" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

# ASSOCIATE PRIVATE SUBNET WITH PRIVATE RT

resource "aws_route_table_association" "subnet_2_assoc" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}