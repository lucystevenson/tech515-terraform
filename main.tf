# coding language is Hashicorp - syntax for HCL is {key=value}
# create an EC2 instance
# cloud provider AWS
# use Ireland region
# which AMI ID ami-0c1c30571d2dae5c9 (for ubuntu 22.04 lts)
# type of instance t3.micro
# need a public IP address
# aws_access_key = ksnwalkwns MUST NOT DO THIS
# aws_secret_key = klednoedk MUST NOT DO THIS
# name the instance: tech515-lucy-tf-first-instance

# create AWS security group

resource "aws_security_group" "tech515-app-sg" {
    # ... other configuration ...
    name = "tech515-lucy-tf-allow-port-22-3000-80"
    description = "Allow port 3000 & 80 from all; allow port 22 from your local machine's IP address"


    # Allow port 3000 from all
    ingress {
        from_port   = 3000
        to_port     = 3000
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow port 80 from all
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
        cidr_blocks = ["86.22.217.28/32"]
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
        Name = "tech515-lucy-tf-allow-port-22-3000-80" # what you want it to be called when it's actually made
    }
}


# create an EC2 instance
# cloud provider is AWS
 
provider "aws" {
    # use Ireland region
    region = "eu-west-1"
}
 
# which service/resource
resource "aws_instance" "app_instance" {
 
    # which AMI ID ami-0c1c30571d2dae5c9 (for ubuntu 22.04 lts)
    ami = "ami-0c1c30571d2dae5c9"
 
    # what type of instance to launch
    instance_type = "t3.micro"
 
    # please add a public ip to this instance
    associate_public_ip_address = true

    # Attach the security group to your EC2 instance:
    vpc_security_group_ids = [aws_security_group.tech515-app-sg.id]   

    # Add public key we made already
    key_name = "tech515-lucy-aws"
    
    # If we want to add public key we made above
    # key_name = aws_key_pair.lucy_key.key_name
 
    # name the service
    tags = {
        Name = "tech515-lucy-tf-first-instance" # what you want it to be called when it's actually made
    }
}