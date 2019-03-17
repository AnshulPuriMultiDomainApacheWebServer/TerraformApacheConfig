/**
 * # aws-terraform output file for the main terraform configuration file, for HA Apache Web Server configuration on AWS
 *
 *
 *This output file outputs the EC2 SSH Key Pair key name, for use in other modules

*/

output "Application_Load_Balancer_DNS_Name" {
  value = "${module.ALB.DNS_Name}"
}


