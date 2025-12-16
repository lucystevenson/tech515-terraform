
#Name: techxxx-yourname-ubuntu-2204-ansible-target-node-app
#Size: t3.micro as usual
#Security group: Allow SSH, HTTP, port 3000 (the usual for the app)
#VPC + subnets: Default ones
#Key pair: Use the one you usually use for your AWS instances (and the same one as you used on the controller)
#Image: Ubuntu Server 22.04 LTS (free tier eligible), NOT your custom app AMI
#User data: Leave it blank - don't run any scripts or user data on it
#Public IP address: yes


# cloud provider is AWS
 
provider "aws" {
    # use Ireland region
    region = var.default_region
}

data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/" #"https://api.ipify.org?format=json" "https://api.ipify.org"
}

locals {
    my_ip_cidrblock = ["${chomp(data.http.my_ip.response_body)}/32"] #my_ip_cidrblock["${chomp(data.http.my_ip.response_body)}/32"] jsondecode(data.http.my_ip.response_body).ip
}

resource "aws_security_group" "tech515_ansible_target_node_sg" {
    # ... other configuration ...
    name = "tech515-lucy-tf-ansible-target-node-allow-port-22-80-3000"
    description = "Allow SSH port 22, HTTP port 80, app port 3000"


    # Allow port 22 my IP
    ingress {
        description = "SSH from my IP"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = local.my_ip_cidrblock # ["${chomp(data.http.my_ip.response_body)}/32"]
    }


    # Allow port 3000 from all
    ingress {
        description = "app port 3000 from anywhere"
        from_port   = 3000
        to_port     = 3000
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow port 80 from all
    ingress {
        description = "HTTP port 80 from anywhere"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow all outbound traffic
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    # name the service
    tags = {
        Name = "tech515-lucy-tf-ansible-target-node-allow-port-22-80-3000" # what you want it to be called when it's actually made
    }
}

resource "aws_instance" "tech515_ansible_target_node_instance" {

    # Ubuntu Server 22.04 LTS (free tier eligible) AMI
    ami = "ami-0c1c30571d2dae5c9"

    # what type of instance to launch
    instance_type = var.target_node_instance_type
 
    # please add a public ip to this instance
    associate_public_ip_address = true

    # Attach the security group to your EC2 instance:
    vpc_security_group_ids = [aws_security_group.tech515_ansible_target_node_sg.id]   

    # Add public key we made already
    key_name = var.public_key_name

    user_data = ""
    
    # name the service
    tags = {
        Name = "tech515-lucy-ubuntu-2204-ansible-target-node-app" # what you want it to be called when it's actually made
    }
}