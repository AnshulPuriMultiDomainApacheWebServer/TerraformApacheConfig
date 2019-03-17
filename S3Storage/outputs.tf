/**
 * # aws-terraform-S3-Storage-ec2userdatafiles
 *
 *This outputs.tf file of the module outputs variables to be used by other modules
*/

output "s3_bucket_ec2userdatafiles" {
  value = "${aws_s3_bucket.s3_bucket_ec2userdatafiles.id}"
}