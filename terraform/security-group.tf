resource "aws_security_group" "stable_diffusion" {
  name        = "stable-diffusion"
  description = "Allows Access to Stable Diffusion"
  vpc_id      = var.VPC_ID

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"

    cidr_blocks = [
      "${var.MY_IP_ADDRESS}/32"
    ]
  }

  ingress {
    description = "Stable Diffusion"
    from_port   = 7860
    to_port     = 7860
    protocol    = "TCP"

    cidr_blocks = [
      "${var.MY_IP_ADDRESS}/32"
    ]
  }

  egress {
    description = "Outbound internet access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "stable-diffusion"
  }
}
