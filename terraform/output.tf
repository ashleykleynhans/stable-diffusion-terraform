output "ip_addresses" {
  value = {
    private_ip = aws_spot_instance_request.stable_diffusion.private_ip
    public_ip  = aws_spot_instance_request.stable_diffusion.public_ip
  }
}