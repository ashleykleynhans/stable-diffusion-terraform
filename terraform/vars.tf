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

variable "VPC_ID" {
  default = ""
}