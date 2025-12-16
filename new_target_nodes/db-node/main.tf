
#Name: techxxx-yourname-ubuntu-2204-ansible-target-node-db
#Size: t3.micro as usual
#Security group: Allow SSH, Mongo DB (the usual for the DB)
#VPC + subnets: Default ones
#Key pair: Use the one you usually use for your AWS instances (and the same one as you used on the controller)
#Image: Ubuntu Server 22.04 LTS (free tier eligible), NOT your custom DB AMI
#User data: Leave it blank - don't run any scripts or user data on it
#Public IP address: yes


# cloud provider is AWS
 
provider "aws" {
    # use Ireland region
    region = "eu-west-1"
}

resource "aws_security_group" "tech515_ansible_NEW_target_node_db_sg" {
    # ... other configuration ...
    name = "tech515-lucy-tf-ansible-NEW-target-node-allow-port-22-27017"
    description = "Allow SSH port 22, mongodb port 27017"


    # Allow port 22 from all
    ingress {
        description = "SSH from anywhere"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow port 27017
    ingress {
        description = "app port 3000 from anywhere"
        from_port   = 27017
        to_port     = 27017
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
        Name = "tech515-lucy-tf-ansible-NEW-target-node-allow-port-22-27017" # what you want it to be called when it's actually made
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
        Name = "tech515-lucy-ubuntu-2204-ansible-NEW-target-node-DB" # what you want it to be called when it's actually made
    }
}