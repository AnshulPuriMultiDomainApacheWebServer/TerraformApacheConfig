/**
 * # aws-terraform-VPC-Flow-Logs-IAM-Role
 *
 *This main.tf file of the module sets up the IAM role with permissions to publish to CloudWatch log group
*/

  # Create the IAM role
resource "aws_iam_role" "vpc_flowlogs_role" {
  name = "vpc_flowlogs_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

  # Create the IAM policy
resource "aws_iam_role_policy" "vpc_flowlogs_policy" {
  name = "vpc_flowlogs_policy"
  role = "${aws_iam_role.vpc_flowlogs_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}