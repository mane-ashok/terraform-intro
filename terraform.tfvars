# by default terraform looks for this file to resolve the variable values, 
#There is an option to have different name for variable files but this needs to be communicated to terraform
# with -var-file option > terraform apply -var-file <file-name>
ami = "ami-0f8ca728008ff5af4"
vpc-cidr = "10.0.0.0/16"
subnets = [{cidr_block = "10.0.1.0/24", name = "public-subnet-1"},{cidr_block = "10.0.2.0/24", name = "public-subnet-2"}]