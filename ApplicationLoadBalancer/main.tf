/**
 * # aws-terraform-ApplicationLoadBalancer, for HA Apache Web Server configuration on AWS
 *
 *This main.tf file of the module sets up the external facing Application Load Balancer in the VPC,
*/

  # Create an App. Load Balancer resource
resource "aws_lb" "alb" {
  name = "alb"
  internal = false
  load_balancer_type = "application"
  security_groups = ["${var.ELB_sg}"]
  subnets = ["${var.public_subnet_ids}"]
  enable_deletion_protection = false

  tags {
    Name = "ALB_${var.customer_name}"
  }
}

  # Create an App. Load Balancer listener resource, on HTTP port 80
resource "aws_lb_listener" "alb_list" {
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.alb_trgt_group.arn}"
  }
}

  # Create an App. Load Balancer listener rule resource, based on the host-header condition
resource "aws_lb_listener_rule" "alb_list_rule" {
  listener_arn = "${aws_lb_listener.alb_list.arn}"
  priority     = 100
  
  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.alb_trgt_group.arn}"
  }

  condition {
    field  = "host-header"
    values = ["*.test.com"]
  }
}

  # Create an App. Load Balancer target group resource
resource "aws_alb_target_group" "alb_trgt_group" {  
  name     = "alb-trgt-group"  
  port     = "80"  
  protocol = "HTTP"  
  vpc_id   = "${var.vpc_id}"  
  
  tags {
    Name = "alb_trgt_group_${var.customer_name}"
  }  
  
  stickiness {    
    type            = "lb_cookie"    
    cookie_duration = 1800    
    enabled         = "true"  
  }   
  
  health_check {    
    healthy_threshold   = 3    
    unhealthy_threshold = 10    
    timeout             = 5    
    interval            = 10    
    path                = "/"    
    port                = "80"  
  }
}

  #Create an autoscaling attachment resource, to attach the ec2 auto-scaling group to the target group
resource "aws_autoscaling_attachment" "autoscaling_attachment_trgt_grp" {
  alb_target_group_arn   = "${aws_alb_target_group.alb_trgt_group.arn}"
  autoscaling_group_name = "${var.ec2autoscaling}"
}

