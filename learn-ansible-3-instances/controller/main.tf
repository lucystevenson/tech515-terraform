
#Name: techxxx-yourname-ubuntu-2204-ansible-controller
#Size: t3.micro as usual
#Security group: Allow SSH port
#VPC + subnets: Default ones
#Key pair: Use the one you usually use for your AWS instances
#Image: Ubuntu Server 22.04 LTS (free tier eligible)
#User data: Leave it blank - don't run any scripts or user data on it
#Public IP address: yes

# cloud provider is AWS
 
provider "aws" {
    # use Ireland region
    region = var.default_region
}

resource "aws_security_group" "tech515_controller_sg" {
    # ... other configuration ...
    name = "tech515-lucy-tf-controller-allow-port-22"
    description = "Allow SSH port 22"


    # Allow port 22 from all
    ingress {
        description = "SSH from all"
        from_port   = 22
        to_port     = 22
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
        Name = "tech515-lucy-tf-controller-allow-port-22" # what you want it to be called when it's actually made
    }
}

resource "aws_instance" "tech515-controller_instance" {

    # Ubuntu Server 22.04 LTS (free tier eligible) AMI
    ami = "ami-0c1c30571d2dae5c9"

    # what type of instance to launch
    instance_type = var.controller_instance_type
 
    # please add a public ip to this instance
    associate_public_ip_address = true

    # Attach the security group to your EC2 instance:
    vpc_security_group_ids = [aws_security_group.tech515_controller_sg.id]   

    # Add public key we made already
    key_name = var.public_key_name

    user_data = ""
    
    # name the service
    tags = {
        Name = "tech515-lucy-ubuntu-2204-ansible-controller" # what you want it to be called when it's actually made
    }
}