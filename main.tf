################################Provider###############################

provider "aws" {
  region = "ap-south-1"
  # terraform will pull the access key and secret key information from the aws profile on the machine
  #access_key = ""
  #secret_key = ""
}

#########################################Resources#####################################


#1. VPC
resource "aws_vpc" "myVPC" {
  cidr_block = var.vpc-cidr
  tags = {
    Name = "production"
  }
}

#2. Internet Gateway(IGW)

resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "MyIGW"
  }
}

#3. Route table

resource "aws_route_table" "myRouteTable" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }
  tags = {
    Name = "my Route Table"
  }
}
#4. subnets
resource "aws_subnet" "mySubnet-1" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = var.subnets[0].cidr_block
  availability_zone = "ap-south-1b"
  tags = {
    Name = var.subnets[0].name
  }
}

resource "aws_subnet" "mySubnet-2" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = var.subnets[1].cidr_block
  availability_zone = "ap-south-1b"
  tags = {
    Name = var.subnets[1].name
  }
}

#5. Associate subnet with route table

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.mySubnet-1.id
  route_table_id = aws_route_table.myRouteTable.id
}
#6. Security group to all allow inbound traffic on 22, 80 and 443 ports

resource "aws_security_group" "allow-web-ssh" {
  name        = "allow ssh and http/s"
  description = "Allow ssh and http/s inbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    description = "Https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web_ssh"
  }
}

#7. Network interface with an IP in the subnet(mySubnet)
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.mySubnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow-web-ssh.id]
}

#8. Assign an EIP to the the network interface
resource "aws_eip" "myEIP" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.myIGW]
}

#9. EC2 with apache installed on it
resource "aws_instance" "web-server" {
    ami = var.ami
    instance_type = "t2.micro"
    availability_zone = "ap-south-1b"
    key_name = "my-ec2-key-pair"

    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.web-server-nic.id
    }

    user_data = <<-EOF
                    #!/bin/bash
                    sudo apt update -y
                    sudo apt install apache2 -y
                    sudo systemctl start apache2
                    sudo bash -c 'echo This is your web server that was created through terraform > /var/www/html/index.html'
                    EOF
    tags = {
      "Name" = "My Web server"
    }

    
}

###################################################Outputs###############################

# Outputs from terraform
#get the output of public ip on console and use it to connect over port 80
output "web-server-public-ip" {
        value = aws_instance.web-server.public_ip
}

###################################################Variables#############################

#variables
variable "ami" {
    description = "AMI for web server"
    #default = 
    type = string  
}

variable "subnets" {
  description = "Subnet cidr block & name"
  #default = 
  type = list

}

variable "vpc-cidr" {
    description = "vpc cidr block"
    #default = 
    type = string
  
}


#resources
#resource "<provider>_<resource type>" "resource name in terraform"{
#    key1 = "value"
#    key2 = "value"
#}

# say, you want to create ec2 instance, search terraform aws ec2 and get the example
#resource "aws_instance" "my-first-ec2" {
#  ami           = "ami-09ba48996007c8b50"
#  instance_type = "t2.micro"
#}

#terraform commands
#terraform init - will download the provider library it needs to connect to provider
#terraform plan - will show dry run of actions it will perform
#terraform apply - will apply the changes
#terraform destroy - will destroy the resources
#terraform destroy -target <specific resource name> - to destroy specific resource
#terraform apply -target <specific resource name> - to apply specific resource
#terraform state list - to list the resource states
#terraform state show <state name> - to see the details of the state
#terraform refresh - Just to refresh the state in terraform, it syncs with the aws resources