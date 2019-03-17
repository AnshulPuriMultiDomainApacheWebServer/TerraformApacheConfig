/**
 * # aws-terraform-Dynamic-EC2-KeyPair, for HA Apache Web Server configuration on AWS
 *
 *This main.tf file of the module generates an EC2 KeyPair to be used in launching EC2 instances
*/


locals {
  public_key_filename  = "${var.keypath}/${var.keyname}.pub"
  private_key_filename = "${var.keypath}/${var.keyname}.pem"
}

resource "tls_private_key" "generated" {
  algorithm = "RSA"
}

resource "aws_key_pair" "generated" {
  key_name   = "${var.keyname}"
  public_key = "${tls_private_key.generated.public_key_openssh}"

  lifecycle {
    ignore_changes = ["key_name"]
  }
}

resource "local_file" "public_key_openssh" {
  count    = "${var.keypath != "" ? 1 : 0 }"
  content  = "${tls_private_key.generated.public_key_openssh}"
  filename = "${local.public_key_filename}"
}

resource "local_file" "private_key_pem" {
  count    = "${var.keypath != "" ? 1 : 0 }"
  content  = "${tls_private_key.generated.private_key_pem}"
  filename = "${local.private_key_filename}"
}
