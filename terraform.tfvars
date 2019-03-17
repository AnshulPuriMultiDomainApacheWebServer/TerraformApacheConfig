/**
 * # aws-terraform main configuration tfvars file for HA Apache Web Server configuration on AWS
 *
 *This TFVARS file should be used/ modified by the user prior to running "terraform plan" and "terraform apply",
 *to enter parameters specific to the deployment for the respective customer.
*/

customer_name = "abccorp"

vpc_cidr = "10.0.0.0/16"

EC2_Apache_instance_type = "t2.micro"

aws_region = "us-west-2"

keyname = "EC2PrivateKey"

keypath = "./SSHkey"

apache_web_instance_ami_id = "ami-db710fa3"

  # the minimum number of instances that should run in the EC2 auto scaling group
auto_scaling_min = 3

  # the maximum number of instances that can run in the EC2 auto scaling group
auto_scaling_max = 6

  # The S3 service name in the chosen region above,
  # , to create the VPC gateway endpoint to S3, for the Apache EC2 instances to GET and PUT config. files from/ to S3
vpc_gateway_endpoint_s3_servicename = "com.amazonaws.us-west-2.s3"



