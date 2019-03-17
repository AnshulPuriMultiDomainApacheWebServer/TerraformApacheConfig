/**
 * # aws-terraform-basenetwork, for HA Apache Web Server configuration on AWS
 *
 *This main.tf file of the module sets up basic network components,
 *including a VPC for an account in a specific region.
*/

  # Get the AZs that are available in the chosen Region 
data "aws_availability_zones" "available_az" {
  state = "available"
}

  # Get the available AZ list
locals {
  available_az_list = "${data.aws_availability_zones.available_az.names}"
}

  # Get the available AZ count
locals {
  available_az_count = "${length(local.available_az_list)}"
}

  # Create the VPC
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "${var.customer_name}"
  }
}

  # Create the IGW and attach to the VPC
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.customer_name}"
  }
}

  # Create the NAT Gateway in each AZ/ public subnet, for maximum redundancy
resource "aws_nat_gateway" "natgw" {
  count = "${local.available_az_count}"
  allocation_id = "${element(aws_eip.nat_eip.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  depends_on = ["aws_subnet.public_subnet","aws_eip.nat_eip"]
}
  
 
  # Create Public Subnets in each AZ, to place the App. Load Balancer
resource "aws_subnet" "public_subnet" {
  count = "${local.available_az_count}"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${element(local.available_az_list, count.index)}"
  cidr_block = "${cidrsubnet(var.vpc_cidr, 8, count.index + 1)}"
  
  tags {
    Name = "PublicSubnet_${element(local.available_az_list, count.index)}_${var.customer_name}"
  }
}
  
  # Create Private Subnets in each AZ, to place the Apache Web Server Instances
resource "aws_subnet" "private_subnet" {
  count = "${local.available_az_count}"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${element(local.available_az_list, count.index)}"
  cidr_block = "${cidrsubnet(var.vpc_cidr, 8, count.index + 5)}"
  
  tags {
    Name = "PrivateSubnet_${element(local.available_az_list, count.index)}_${var.customer_name}"
  }
}

  # Public Subnet route table
resource aws_route_table "public_route_table" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "Public_Route_${var.customer_name}"
  }
}

  # Private Subnet route table
  resource "aws_route_table" "private_route_table" {
  count = "${local.available_az_count}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "PrivateSubnetRouteTable_${element(local.available_az_list, count.index)}_${var.customer_name}"
  }
}
  
  # EIP for the NAT Gateway
resource "aws_eip" "nat_eip" {
  count = "${local.available_az_count}"
  vpc = true
  depends_on = ["aws_internet_gateway.internet_gateway"]
}

  # Public Route Table Entry
resource "aws_route" "public_routes" {
  route_table_id = "${aws_route_table.public_route_table.id}"
  gateway_id = "${aws_internet_gateway.internet_gateway.id}"
  destination_cidr_block = "0.0.0.0/0"
  depends_on = ["aws_internet_gateway.internet_gateway"]
}
  
  # Public Route Table Association with Public Subnet
resource "aws_route_table_association" "public_route_association" {
  count = "${local.available_az_count}"
  subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_route_table.id}"
  depends_on = ["aws_subnet.public_subnet","aws_route_table.public_route_table"]
}

  # Private Route Table Entry
resource "aws_route" "private_routes" {
  count = "${local.available_az_count}"
  route_table_id = "${element(aws_route_table.private_route_table.*.id, count.index)}"
  nat_gateway_id = "${element(aws_nat_gateway.natgw.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  depends_on = ["aws_nat_gateway.natgw","aws_route_table.private_route_table"]
}
  
  # Private Route Table Association with Private Subnet
resource "aws_route_table_association" "private_route_association" {
  count = "${local.available_az_count}"
  subnet_id = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private_route_table.*.id, count.index)}"
  depends_on = ["aws_subnet.private_subnet","aws_route_table.private_route_table"]
}

  # NACL for the Public and Private Subnet
resource "aws_network_acl" "nacl" {
  vpc_id = "${aws_vpc.vpc.id}"
  subnet_ids = ["${aws_subnet.private_subnet.*.id}","${aws_subnet.public_subnet.*.id}"]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags {
    Name = "NACL_${var.customer_name}"
  }
}

  # SG for the ELB
resource "aws_security_group" "ELB_sg" {
  name        = "ELB_sg"
  description = "Used as a reverse proxy-load balancer for apache web server"
  vpc_id      = "${aws_vpc.vpc.id}"

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow inbound traffic from VPC on ephemeral ports
  ingress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags {
    Name = "Public_ELB_SG_${var.customer_name}"
  }
}

  # SG for the Apache Web Server Instances
resource "aws_security_group" "apache_web_instance_sg" {
  name        = "apache_web_instance_sg"
  description = "Used for securing the apache web instances"
  vpc_id      = "${aws_vpc.vpc.id}"
  depends_on    = ["aws_security_group.ELB_sg"]

  #HTTP, only allow inbound traffic from the App. Load Balancer
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = ["${aws_security_group.ELB_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    prefix_list_ids = ["${aws_vpc_endpoint.VPC_gateway_endpoint_S3.prefix_list_id}"]
  }
  
  tags {
    Name = "Apache_Web_SG_${var.customer_name}"
  }
}

  # Create the cloudwatch log group for VPC Flow Logs, only retain for 30 days
resource "aws_cloudwatch_log_group" "VPCFlowLogs" {
  retention_in_days = 30
}

  # Create the flow logs to capture traffic from all Network Interfaces in the VPC
resource "aws_flow_log" "VPCFlowLogs" {
  iam_role_arn    = "${var.vpc_flowlogs_role_arn}"
  log_destination = "${aws_cloudwatch_log_group.VPCFlowLogs.arn}"
  traffic_type    = "ALL"
  vpc_id          = "${aws_vpc.vpc.id}"
}

  #Create a VPC gateway endpoint to S3, for the Apache EC2 instances to GET and PUT config. files from/ to S3
resource "aws_vpc_endpoint" "VPC_gateway_endpoint_S3" {
  vpc_id = "${aws_vpc.vpc.id}"
  route_table_ids = ["${aws_route_table.private_route_table.*.id}"]
  service_name = "${var.vpc_gateway_endpoint_s3_servicename}"
}



