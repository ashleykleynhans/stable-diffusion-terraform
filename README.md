# Create an AWS EC2 GPU Spot Instance to Run Stable Diffusion WebUI and DreamBooth using Terraform

## Overview

Install the [Stable Diffusion WebUI by AUTOMATIC1111](
https://github.com/AUTOMATIC1111/stable-diffusion-webui)
and [Dreambooth Extension](
https://github.com/d8ahazard/sd_dreambooth_extension)
on an AWS EC2 GPU spot instance for the fraction of the
cost of an on-demand instance.

A Python script is provided to assist you with determining
your bid prince for the spot EC2 instance, and [Terraform](
https://www.terraform.io/) code is provided to assist you
with provisioning the EC2 instance in AWS.

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
* EC2_INSTANCE_DISK_SIZE
* VPC_ID
* SUBNET_ID
* MY_IP_ADDRESS

The default disk size is 100GB, but if you plan on experimenting
with multiple models and doing training, I recommend increasing
it to around 300GB, depending on your requirements.

### Create a terraform.tfvars file containing your AWS credentials

Create a `terraform.tf` file with the following content:

```
AWS_ACCESS_KEY = "INSERT_YOUR_ACCESS_KEY"
AWS_SECRET_KEY = "INSERT_YOUR_SECRET_KEY"
```

### Check what AWS resources are going to be created

```bash
terraform plan
```

### Create the AWS resources

```bash
terraform apply
```

This will create your EC2 instance, and will output the
private IP and the public IP.

Take note of the public IP and use it to SSH to the
server using the username `ubuntu` and the private
key that you have specified in `vars.tf`.

### Run Stable Diffusion

Once the AWS resources are created by Terraform,
`cloud-init` will take quite some time to install all the
necessary dependencies (`scripts/setup.sh`), and will
reboot the instance in order for the CUDA driver to
take effect once its installed.

You can check the progress by establishing an SSH
connection to the server and running the following
command:

```bash
tail -f /var/log/cloud-init-output.log
```

You should see something like this once everything
is installed:

```
Cloud-init v. 23.1.2-0ubuntu0~22.04.1 finished at Fri, 12 May 2023 14:54:27 +0000. Datasource DataSourceEc2Local.  Up 10.65 seconds
```

Once the server is ready, you can start Stable Diffusion
as follows:

```bash
/home/ubuntu/stable-diffusion-terraform/scripts/run.sh
```

This will automatically start tailing the logs, which
is especially useful if you are going to be doing training
using the Dreambooth extension.

## Destroy the Stable Diffusion AWS resources

Once you are done using Stable Diffusion, training
your model, etc, you should destroy the AWS resources
so that you are not charged for them.

If you trained any models, be sure to copy them
off the server before destroying the resources,
otherwise they will be lost forever.

```bash
terraform destroy
```

## Troubleshooting

### GPU OOM issues

See the the [Dreambooth extension wiki](https://github.com/d8ahazard/sd_dreambooth_extension/wiki/Troubleshooting#OOM).
