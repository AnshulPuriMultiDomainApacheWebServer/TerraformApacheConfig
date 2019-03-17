/**
 * # aws-terraform-ApplicationLoadBalancer, for HA Apache Web Server configuration on AWS
 *
 *This variables.tf file of the module declares the variables used by the main.tf file of the module
*/


variable "customer_name" {}

variable "ELB_sg" {}

variable "public_subnet_ids" {
  type    = "list"
}

variable "vpc_id" {}

variable "ec2autoscaling" {}





