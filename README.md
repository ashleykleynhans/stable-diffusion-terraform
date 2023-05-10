# Create an AWS EC2 GPU Spot Instance to Run Stable Diffusion WebUI and DreamBooth using Terraform

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

### Run the script

```bash
python3 get_spot_price.py -r eu-west-1 -i g4dn.xlarge
```

Where `eu-west-1` is the region, and `g4dn.xlarge` is the EC2
instance type.

This will return the spot price, for example `0.24192`.

## Create your Stable Diffusion EC2 instance

### Install Terraform

```bash
brew install terraform
```

### Initialise Terraofrm

```bash
terraform init
```

### Update the Terraform configuration

Edit `terraform/vars.tf`, and update the following variables:

* AWS_REGION
* AWS_KEY_PAIR
* EC2_INSTANCE_TYPE
* EC2_INSTANCE_SPOT_PRICE
* VPC_ID


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