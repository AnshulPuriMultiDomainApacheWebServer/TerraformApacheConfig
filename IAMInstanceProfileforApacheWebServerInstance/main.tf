/**
 * # aws-terraform-EC2-IAM-Instance-Profile
 *
 *This main.tf file of the module sets up the EC2 IAM Instance Profile for the Apache Web Server Instances
*/

  # Create an IAM role
resource "aws_iam_role" "ec2_iam_role" {
    name = "ec2_iam_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

  # Create an IAM instance profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
    name = "ec2_instance_profile"
    role = "${aws_iam_role.ec2_iam_role.name}"
}

  # Null resource which takes the creation of S3 bucket in the S3Storage module as a trigger
resource "null_resource" "trigger_ec2_iam_role_policy" {

  triggers = {
    trigger_ec2_iam_role_policy_id = "${var.s3_bucket_ec2userdatafiles}"
  }

  provisioner "local-exec" {
  
      command = "echo run"
  }
}

  # Create the IAM policy to attach to the IAM role
resource "aws_iam_role_policy" "ec2_iam_role_policy" {
  name = "ec2_iam_role_policy"
  role = "${aws_iam_role.ec2_iam_role.id}"
  depends_on = ["null_resource.trigger_ec2_iam_role_policy"]
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*",
				"cloudwatch:*",
                "ds:CreateComputer",
                "ds:DescribeDirectories",
                "ec2:DescribeInstanceStatus",
                "logs:*",
                "ssm:*",
                "ec2messages:*"
            ],
            "Resource": "*"
        },
		{
           "Effect": "Allow",
           "Action": [
                "s3:*"
            ],
            "Resource": "arn:aws:s3:::${var.s3_bucket_ec2userdatafiles}/*"
		},
		{
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::${var.s3_bucket_ec2userdatafiles}"
        }
  ]
}
EOF
}