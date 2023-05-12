variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}

variable "AWS_REGION" {
  default = "eu-west-1"
}

variable "AWS_KEY_PAIR" {
  default = "YOUR_KEY_PAIR"
}

variable "EC2_INSTANCE_TYPE" {
  default = "g4dn.xlarge"
}

variable "EC2_INSTANCE_SPOT_PRICE" {
  default = "0.24192"
}

variable "EC2_INSTANCE_DISK_SIZE" {
  default = 100
}

variable "VPC_ID" {
  default = "vpc-xxxxxxxxxxxxxxxx"
}

# The subnet ID must be in the same availability zone as above
variable "SUBNET_ID" {
  default = "subnet-xxxxxxxxxxxxxxxxx"
}

variable "MY_IP_ADDRESS" {
  default = "192.168.1.1"
}