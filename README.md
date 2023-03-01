# terraform-intro
This repo will create new VPC with 2 public subnets and the webserver with apache2 installed on it.
The security group exposes port 22, 80 and 443 from any IP address
terraform script outputs public IP of the webserver which you can use to connect over http on port 80
The expected output : This is your web server that was created through terraform

All the variables are defined in terraform.tfvars file and the resources in main.tf file
You need to set up aws profile on the machine from there terraform will use access key and secret access key.

Steps -
1. clone the repo
2. make sure you have the aws profile setup
3. make sure terraform is installed on the machine
4. run below commands
5. terraform init - this will downaload aws plugins required for terraform
6. terraform apply - this will create all the resources
7. grab the server IP from the outputs and hit the url in browser - http://public-ip:80
8. Expected output - This is your web server that was created through terraform
9. terrafrom destroy - This will destroy all the resources
