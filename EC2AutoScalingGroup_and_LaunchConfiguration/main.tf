/**
 * # aws-terraform-EC2AutoScalingGroup_and_LaunchConfiguration, for HA Apache Web Server configuration on AWS
 *
 *This main.tf file of the module sets up the EC2 AutoScalingGroup and Launch Configuration in the VPC,
*/

  # Create a resource for EC2 placement group, 
  # with spread strategy to build redundancy for EC2 hypervisor/ host hardware failures 
resource "aws_placement_group" "ec2_place_spread" {
  name     = "ec2_place_spread"
  strategy = "spread"
}

 # Null resource which takes the creation of S3 bucket in the S3Storage module as a trigger
resource "null_resource" "trigger_userdata_apache" {

  triggers = {
    trigger_userdata_apache_id = "${var.s3_bucket_ec2userdatafiles}"
  }

  provisioner "local-exec" {
  
      command = "echo run"
  }
}

  # Build a data source for a bash script, to install and configure Apache Web Server
data "template_file" "userdata_apache" {
  template = "${file("${path.module}/userdata_apache.tpl")}"
  depends_on = ["null_resource.trigger_userdata_apache"]

  vars {
    s3_bucket_ec2userdatafiles = "${var.s3_bucket_ec2userdatafiles}"
}
}

  # Copy the www.test.com domain .conf file to S3 Bucket, from the current module directory
resource "aws_s3_bucket_object" "copy_test_s3" {
  bucket = "${var.s3_bucket_ec2userdatafiles}"
  key    = "www.test.com.conf"
  source = "${path.module}/www.test.com.conf"
  depends_on = ["null_resource.trigger_userdata_apache"]
}

  # Copy the ww2.test.com domain .conf file to S3 Bucket, from the current module directory
resource "aws_s3_bucket_object" "copy_test2_s3" {
  bucket = "${var.s3_bucket_ec2userdatafiles}"
  key    = "ww2.test.com.conf"
  source = "${path.module}/ww2.test.com.conf"
  depends_on = ["null_resource.trigger_userdata_apache"]
}

  # Create a resource for EC2 launch configuration, with the IAM instance profile attached
resource "aws_launch_configuration" "ec2launchconfig" {
  name_prefix          = "ec2launchconfig"
  image_id             = "${var.apache_web_instance_ami_id}"
  instance_type        = "${var.EC2_Apache_instance_type}"
  key_name             = "${var.key_name}"
  security_groups      = ["${var.apache_web_instance_sg}"]
  user_data            = "${data.template_file.userdata_apache.rendered}"
  iam_instance_profile = "${var.ec2_iam_instance_profile}"
  depends_on           = ["aws_s3_bucket_object.copy_test_s3","aws_s3_bucket_object.copy_test2_s3"]
}

  # Create a resource for EC2 auto scaling group,
  # , enable ELB health checks for both EC2 system/ instance checks and ELB related checks  
resource "aws_autoscaling_group" "ec2autoscaling" {
  name = "ec2autoscaling"
  vpc_zone_identifier  = ["${var.private_subnet_ids}"]
  launch_configuration = "${aws_launch_configuration.ec2launchconfig.name}"
  placement_group = "${aws_placement_group.ec2_place_spread.id}"
  min_size = "${var.auto_scaling_min}"
  max_size = "${var.auto_scaling_max}"
  health_check_grace_period = 300
  health_check_type = "ELB"
  force_delete = true
  depends_on = ["aws_s3_bucket_object.copy_test_s3","aws_s3_bucket_object.copy_test2_s3"]
  enabled_metrics = ["GroupMinSize","GroupMaxSize","GroupDesiredCapacity","GroupInServiceInstances","GroupPendingInstances","GroupStandbyInstances","GroupTerminatingInstances","GroupTotalInstances"] 

  tag {
    key = "Name"
    value = "ec2 instance in auto scale group ${var.customer_name}"
    propagate_at_launch = true
  }
}

  # Create a dynamic scaling up policy for the auto-scaling group, using the simple scaling policy type,
  # , based on the CPU utlization metric of the Apache Web Server instances
resource "aws_autoscaling_policy" "auto_scale_up_policy" {
  name = "auto_scale_up_policy"
  scaling_adjustment = 1
  policy_type = "SimpleScaling"
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.ec2autoscaling.name}"
}

  # Create a dynamic scaling down policy for the auto-scaling group, using the simple scaling policy type,
  # , based on the CPU utlization metric of the Apache Web Server instances
resource "aws_autoscaling_policy" "auto_scale_down_policy" {
  name = "auto_scale_down_policy"
  scaling_adjustment = -1
  policy_type = "SimpleScaling"
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.ec2autoscaling.name}"
}

  # Create a cloud watch metric alarm for the dynamic scaling up policy,
  # , based on the CPU utlization metric of the Apache Web Server instances, if GE to 75%, scale up
resource "aws_cloudwatch_metric_alarm" "cpualarm_up" {
  alarm_name = "cpualarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "75"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.ec2autoscaling.name}"
  }

  alarm_description = "This metric monitors the EC2 instance upper threshold of cpu utilization"
  alarm_actions = ["${aws_autoscaling_policy.auto_scale_up_policy.arn}"]
}

  # Create a cloud watch metric alarm for the dynamic scaling down policy,
  # , based on the CPU utlization metric of the Apache Web Server instances, , if LE to 10%, scale down
resource "aws_cloudwatch_metric_alarm" "cpualarm_down" {
  alarm_name = "cpualarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "10"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.ec2autoscaling.name}"
  }

  alarm_description = "This metric monitors the EC2 instance lower threshold of cpu utilization"
  alarm_actions = ["${aws_autoscaling_policy.auto_scale_down_policy.arn}"]
}