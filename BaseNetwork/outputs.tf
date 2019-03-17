/**
 * # aws-terraform-basenetwork, for HA Apache Web Server configuration on AWS
 *
 *This outputs.tf file of the module outputs variables to be used in other modules
*/

output "vpc_id" {
  value       = "${aws_vpc.vpc.id}"
}

output "public_subnet_ids" {
  value       = "${aws_subnet.public_subnet.*.id}"
  description = "All the Public Subnet IDs that were created"
}

output "private_subnet_ids" {
  value       = "${aws_subnet.private_subnet.*.id}"
  description = "All the Private Subnet IDs that were created"
}

output "ELB_sg" {
  value = "${aws_security_group.ELB_sg.id}"
}

output "apache_web_instance_sg" {
  value = "${aws_security_group.apache_web_instance_sg.id}"
}

