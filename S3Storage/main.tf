/**
 * # aws-terraform-S3-Storage-ec2userdatafiles
 *
 *This main.tf file of the module sets up S3 Buckets, to store files needed during EC2 userdata setup,
 *to be used to store files such as apache conf files and userdata logs.
**/

  # Create a random id 
resource "random_id" "rm_tf_bucket_id" {
  byte_length = 2
}

  # Create the S3 bucket
resource "aws_s3_bucket" "s3_bucket_ec2userdatafiles" {
  bucket = "${var.customer_name}-ec2userdatafiles-${random_id.rm_tf_bucket_id.dec}"
  acl = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  tags {
    Name = "ec2userdatafiles_${var.customer_name}"
  }
}