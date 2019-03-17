/**
 * # aws-terraform-ApplicationLoadBalancer, for HA Apache Web Server configuration on AWS
 *
 *This outputs.tf file of the module outputs variables to be used in other modules
*/

output "DNS_Name" {
  value = "${aws_lb.alb.dns_name}"
}