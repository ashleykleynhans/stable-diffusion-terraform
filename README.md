# Create an AWS EC2 GPU Spot Instance to Run Stable Diffusion WebUI and DreamBooth using Terraform

## Overview

If you want to use Stable Diffusion on its own, a `g4dn.xlarge`
EC2 instance type with 16GB of memory should suffice.  However,
if you intend on using Dreambooth for training, I've found that
16GB of memory is insufficient, and that a `g4dn.2xlarge`
instance with 32GB of memory is required.

## Clone the repo

```bash
git clone https://github.com/ashleykleynhans/stable-diffusion-terraform.git
cd  stable-diffusion-terraform
```

## Calculate the spot price for the EC2 GPU instance

### Create the Python virtual environment

```bash
cd scripts
python3 -m venv venv
source venv/bin/activate
python3 -m pip install --upgrade pip
pip3 install -r requirements.txt
```

### Configure your AWS credentials for the script

Edit the `config.yml` file and replace `YOUR_ACCESS_KEY_ID`
and `YOUR_SECRET_ACCESS_KEY` with your actual AWS credentials.

### Run the script to calculate the spot price

```bash
python3 get_spot_price.py -r eu-west-1 -i g4dn.2xlarge
```

Where `eu-west-1` is the region, and `g4dn.2xlarge` is the EC2
instance type.

This will return the spot price, for example `0.37464`.

## Create your Stable Diffusion EC2 instance

### Ensure you are in the Terraform directory

```bash
pwd
```

If you are in the `scripts` directory:

```bash
cd ../terraform
```

If you are in the root of the project:

```bash
cd terraform
```

### Install Terraform

```bash
brew install terraform
```

### Initialise Terraform

```bash
terraform init
```

### Update the Terraform configuration

Get your IP address:

```bash
curl https://icanhazip.com
```

Then edit `terraform/vars.tf`, and update the following variables:

* AWS_REGION
* AWS_KEY_PAIR
* EC2_INSTANCE_TYPE
* EC2_INSTANCE_SPOT_PRICE
* VPC_ID
* AVAILABILITY_ZONE
* SUBNET_ID
* MY_IP_ADDRESS

### Check what AWS resources are going to be created

```bash
terraform plan
```

### Create the AWS resources

```bash
terraform apply
```

## Destroy the Stable Diffusion AWS resources

```bash
terraform destroy
```

## Troubleshooting

### GPU OOM issues

See the the [Dreambooth extension wiki](https://github.com/d8ahazard/sd_dreambooth_extension/wiki/Troubleshooting#OOM).
