/**
 * # aws-terraform main var file for HA Apache Web Server configuration on AWS
 *
 *This variable file declares the variables used by the main terraform configuration file,
*/

variable "access_key" {}

variable "secret_key" {}

variable "aws_region" {}

variable "customer_name" {}

variable "vpc_cidr" {}

variable "EC2_Apache_instance_type" {}

variable "keyname" {}

variable "keypath" {}

variable "apache_web_instance_ami_id" {}

variable "auto_scaling_min" {}

variable "auto_scaling_max" {}

variable "vpc_gateway_endpoint_s3_servicename" {}



