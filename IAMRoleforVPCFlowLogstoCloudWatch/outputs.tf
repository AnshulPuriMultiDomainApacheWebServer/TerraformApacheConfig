/**
 * # aws-terraform-VPC-Flow-Logs-IAM-Role
 *
 *This outputs.tf file of the module outputs variables to be used by other modules
*/

output "vpc_flowlogs_role_arn" {
  value = "${aws_iam_role.vpc_flowlogs_role.arn}"
}


