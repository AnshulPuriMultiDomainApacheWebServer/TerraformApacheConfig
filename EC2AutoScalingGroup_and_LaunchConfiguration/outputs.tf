/**
 * # aws-terraform-EC2AutoScalingGroup_and_LaunchConfiguration, for HA Apache Web Server configuration on AWS
 *
 *This outputs.tf file of the module outputs variables to be used in other modules
*/

output "ec2autoscaling" {
  value = "${aws_autoscaling_group.ec2autoscaling.id}"
}