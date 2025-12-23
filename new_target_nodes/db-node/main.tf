
# cloud provider is AWS
 
provider "aws" {
    # use Ireland region
    region = "eu-west-1"
}

data "aws_security_group" "tech515_controller_sg" {
  name = "tech515-lucy-tf-controller-allow-port-22"
}
 
data "aws_security_group" "tech515_ansible_target_node_app_sg" {
  name = "tech515-lucy-new-target-node-app-allow-port-22-80-3000"
}

resource "aws_security_group" "tech515_ansible_NEW_target_node_db_sg" {
    # ... other configuration ...
    name = "tech515-lucy-tf-ansible-NEW-target-node-allow-port-22-27017"
    description = "Allow SSH from controller and MongoDB from app"


    # Allow port 22 from all
    ingress {
        description = "SSH from controller sg"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        security_groups = [data.aws_security_group.tech515_controller_sg.id]
    }

    # Allow port 27017
    ingress {
        description = "Port 27017 from target_node_app_sg"
        from_port   = 27017
        to_port     = 27017
        protocol    = "tcp"
        security_groups = [data.aws_security_group.tech515_ansible_target_node_app_sg.id]
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
        Name = "tech515-lucy-new-target-node-db-allow-port-22-27017" # what you want it to be called when it's actually made
    }
}

resource "aws_instance" "tech515_ansible_NEW_target_node_db_instance" {

    # Ubuntu Server 22.04 LTS (free tier eligible) AMI
    ami = "ami-0c1c30571d2dae5c9"

    # what type of instance to launch
    instance_type = "t3.micro"
 
    # please add a public ip to this instance
    associate_public_ip_address = true

    # Attach the security group to your EC2 instance:
    vpc_security_group_ids = [aws_security_group.tech515_ansible_NEW_target_node_db_sg.id]   

    # Add public key we made already
    key_name = "tech515-lucy-aws"

    user_data = ""
    
    # name the service
    tags = {
        Name = "tech515-lucy-new-node-db" # what you want it to be called when it's actually made
    }
}