# TerraformApacheConfig
This Terraform config repo deploys a HA Apache Web Server configuration to service multiple domains/ sites in an AWS region, 
with redundancy at the AZ, EC2 Hypervisor Host and EC2 Instance levels, along with EC2 auto scaling policies for scale up/ down based on Apache Web Server instance CPU utilization.


In order to use the repo, follow the below steps-:

1) Terraform state file will be stored in a remote state file, in a S3 bucket, in the same AWS account that will be used to deploy the TerraformApacheConfig, please follow the steps in the following GitHub Repo to deploy the S3 bucket - https://github.com/AnshulPuriMultiDomainApacheWebServer/TerraformS3_remote_state


2) Once done with Step 1, note down the S3 bucket name and AWS Region that is an output at the end of running the Terraform config. in Step 1

3) Clone or unzip the TerraformApacheConfig GitHub repo to a directory on your local workstation, set the AWS CLI credentials and AWS region to deploy, in your local workstation, for a user with Full Admin Access in IAM in the AWS account you wish to deploy

4) Run the below commands, once you have modified the terraform.tfvars file (in the top level directory) for appropriate input variable values,


terraform get -update

terraform init (Enter the S3 bucket name and AWS Region from Step 2 here)

terraform plan

terraform apply

5) The DNS endpoint of the ALB is an output at the end


   
