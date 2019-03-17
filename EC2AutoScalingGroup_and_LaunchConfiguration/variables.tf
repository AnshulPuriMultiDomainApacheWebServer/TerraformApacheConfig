/**
 * # aws-terraform-EC2AutoScalingGroup_and_LaunchConfiguration, for HA Apache Web Server configuration on AWS
 *
 *This variables.tf file of the module declares the variables used by the main.tf file of the module
*/


variable "customer_name" {}

variable "private_subnet_ids" {
  type    = "list"
}

variable "key_name" {}

variable "apache_web_instance_sg" {}

variable "apache_web_instance_ami_id" {}

variable "EC2_Apache_instance_type" {}

variable "auto_scaling_min" {}

variable "auto_scaling_max" {}

variable "s3_bucket_ec2userdatafiles" {}

variable "ec2_iam_instance_profile" {}



