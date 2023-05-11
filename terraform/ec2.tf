data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_spot_instance_request" "stable_diffusion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.EC2_INSTANCE_TYPE
  key_name                    = var.AWS_KEY_PAIR
  spot_price                  = var.EC2_INSTANCE_SPOT_PRICE
  subnet_id                   = var.SUBNET_ID
  spot_type                   = "one-time"
  wait_for_fulfillment        = true
  associate_public_ip_address = true

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 300
    encrypted             = false
    delete_on_termination = true
  }

  vpc_security_group_ids = [
    aws_security_group.stable_diffusion.id
  ]

  tags = {
    Name = "stable-diffusion"
  }

  user_data = <<EOF
#!/usr/bin/env bash
su - ubuntu -c "cd /home/ubuntu && git clone https://github.com/ashleykleynhans/stable-diffusion-terraform.git"
su - ubuntu -c "/home/ubuntu/stable-diffusion-terraform/scripts/setup.sh"
EOF
}

resource "aws_ebs_volume" "stable_diffusion_models" {
  availability_zone = var.AVAILABILITY_ZONE
  size              = 60
  type              = "io2"
  encrypted         = false
  iops              = 3000

  tags = {
    Name = "stable-diffusion"
  }
}

resource "aws_volume_attachment" "stable_diffusion_models" {
  device_name = "/dev/sdf"
  instance_id = aws_spot_instance_request.stable_diffusion.spot_instance_id
  volume_id   = aws_ebs_volume.stable_diffusion_models.id
}