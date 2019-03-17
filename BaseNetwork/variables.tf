/**
 * # aws-terraform-basenetwork, for HA Apache Web Server configuration on AWS
 *
 *This variables.tf file of the module declares the variables used by the main.tf file of the module
*/


variable "customer_name" {}

variable "vpc_cidr" {}

variable "vpc_flowlogs_role_arn" {}

variable "vpc_gateway_endpoint_s3_servicename" {}


