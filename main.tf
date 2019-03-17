/**
 * # aws-terraform main configuration file for HA Apache Web Server configuration on AWS
 *
 *This configuration file calls all the component modules in the GitHub repository,
 *You will need to provide AWS CLI credentials for an IAM user in the new AWS account created for the customer,
 *with FullAdminAccess rights and also the AWS region of the deployment
**/

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.aws_region}"
}

  # Deploy the terraform state file remotely on S3, for security and teamwork purposes
  # , the S3 bucket mentioned below should exist prior to running this configuration file
  # , give same region below, as the region of the S3 Bucket
terraform {
  backend "s3" {
    key = "terraform.tfstate"
  }
}

  # Deploy BaseNetwork Resource
module "BaseNetwork" {
  source = "github.com/AnshulPuriProblemSet/TerraformApache/BaseNetwork"
  customer_name = "${var.customer_name}"
  vpc_cidr = "${var.vpc_cidr}"
  vpc_flowlogs_role_arn = "${module.IAMRoleforVPCFlowLogs.vpc_flowlogs_role_arn}"
  vpc_gateway_endpoint_s3_servicename = "${var.vpc_gateway_endpoint_s3_servicename}"
}

  # Deploy the S3 Buckets for storing config. and userdata related files
module "S3Storage" {
  source = "github.com/AnshulPuriProblemSet/TerraformApache/S3Storage"
  customer_name = "${var.customer_name}"
  ec2_iam_role_arn = "${module.ApacheEC2IAMRole.ec2_iam_role_arn}"
}

  # Deploy Application Load Balancer Resource
module "ALB" {
  source = "github.com/AnshulPuriProblemSet/TerraformApache/ApplicationLoadBalancer"
  customer_name = "${var.customer_name}"
  ELB_sg = "${module.BaseNetwork.ELB_sg}"
  public_subnet_ids = "${module.BaseNetwork.public_subnet_ids}"
  vpc_id = "${module.BaseNetwork.vpc_id}"
  ec2autoscaling = "${module.EC2AutoScalingGroup.ec2autoscaling}"
}

  # Deploy the EC2 Auto-Scaling Group in the private subnets 
module "EC2AutoScalingGroup" {
  source = "github.com/AnshulPuriProblemSet/TerraformApache/EC2AutoScalingGroup_and_LaunchConfiguration"
  customer_name = "${var.customer_name}"
  private_subnet_ids = "${module.BaseNetwork.private_subnet_ids}"
  apache_web_instance_sg = "${module.BaseNetwork.apache_web_instance_sg}"
  EC2_Apache_instance_type = "${var.EC2_Apache_instance_type}"
  key_name = "${module.keypair.key_name}"
  apache_web_instance_ami_id = "${var.apache_web_instance_ami_id}"
  auto_scaling_min = "${var.auto_scaling_min}"
  auto_scaling_max = "${var.auto_scaling_max}"
  s3_bucket_ec2userdatafiles = "${module.S3Storage.s3_bucket_ec2userdatafiles}"
  ec2_iam_instance_profile = "${module.ApacheEC2IAMRole.ec2_iam_instance_profile}"
}

  # Deploy EC2 SSH Key Pair Dynamically on AWS, to be used for launching EC2 instances,
  # , private key gets stored in the Terraform root module directory in a directory called "SSH",
  # , on the client machine where Terraform is run
module "keypair" {
  source = "github.com/AnshulPuriProblemSet/TerraformApache/DynamicEC2KeyPair"
  keypath   = "${var.keypath}"
  keyname   = "${var.keyname}"
}

  # Create the IAM Instance Profile for the Apache Web Server EC2 instances
module "ApacheEC2IAMRole" {
  source = "github.com/AnshulPuriProblemSet/TerraformApache/IAMInstanceProfileforApacheWebServerInstance"
  s3_bucket_ec2userdatafiles = "${module.S3Storage.s3_bucket_ec2userdatafiles}"
}

  # Create the IAM Role for VPC Flow Logs, with publish to CloudWatch Logs group permissions
module "IAMRoleforVPCFlowLogs" {
  source = "github.com/AnshulPuriProblemSet/TerraformApache/IAMRoleforVPCFlowLogstoCloudWatch"
}




