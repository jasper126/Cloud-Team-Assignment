#Network #############################################################################################
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
  default     = "172.16.0.0/16"  # Add your specific VPC ID here 
}
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "172.16.0.0/16" # Update with your desired CIDR block
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "172.16.11.0/24" # Update with your desired CIDR block
}

variable "private_subnet_cidr_block" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "172.16.10.0/24" # Update with your desired CIDR block
}

variable "availability_zone_public" {
  description = "Availability zone for the public subnet"
  type        = string
  default     = "us-east-1b" # Update with your desired availability zone
}

variable "availability_zone_private" {
  description = "Availability zone for the private subnet"
  type        = string
  default     = "us-east-1a" # Update with your desired availability zone
}
# VM options ################################################################################################
variable "instance_ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0e731c8a588258d0d" # Update with your desired AMI ID
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t2.micro" # Update with your desired type
}

variable "userdata_script_path" {
  description = "Path to the user data script"
  type        = string
  default     = "C:/terraform/files/templates/userdata.sh"  # Update with your path
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "172.16.10.0/24" # Update with your desired CIDR block
}

#MySQL user details ########################################################################################

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "mySQL-db-creds1" # Update with your own created secretID in Secret management portal
}
locals {
  mySQL_db_creds1 = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
}

output "mySQL_db_creds1" {
  value     = local.mySQL_db_creds1
  sensitive = true
}

