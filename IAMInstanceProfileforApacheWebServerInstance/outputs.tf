/**
 * # aws-terraform-EC2-IAM-Instance-Profile
 *
 *This outputs.tf file of the module outputs variables to be used by other modules
*/

output "ec2_iam_instance_profile" {
  value = "${aws_iam_instance_profile.ec2_instance_profile.name}"
}

output "ec2_iam_role_arn" {
  value = "${aws_iam_role.ec2_iam_role.arn}"
}

