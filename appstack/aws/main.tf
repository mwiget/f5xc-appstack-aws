resource "volterra_token" "site" {
  name      = var.f5xc_cluster_name
  namespace = var.f5xc_namespace
}

resource "aws_key_pair" "aws_key" {
  key_name   = var.f5xc_cluster_name
  public_key = var.ssh_public_key
}

module "maurice" {
  source        = "../../modules/utils/maurice"
  f5xc_api_url = var.f5xc_api_url
}

resource "aws_vpc" "vpc" {
  count                 = var.create_new_aws_vpc  ? 1 : 0
  tags                  = merge({ "Name" = var.f5xc_cluster_name }, local.common_tags)  
  cidr_block            = var.aws_vpc_cidr_block
  enable_dns_support    = true
  enable_dns_hostnames  = true
}

resource "aws_subnet" "slo" {
  for_each          = { for k in var.vpc_subnets: k.availability_zone => k }
  tags              = merge({ "Name" = format("%s-%s", var.f5xc_cluster_name, each.value.availability_zone) }, local.common_tags)
  vpc_id            = aws_vpc.vpc[0].id
  cidr_block        = each.value.cidr_block
  availability_zone = format("%s%s", var.f5xc_aws_region, each.value.availability_zone)
#  lifecycle {
#    ignore_changes = [tags]
  #  }
}

resource "aws_security_group" "allow_traffic" {
  name        = "${var.f5xc_cluster_name}-allow-traffic"
  description = "allow ssh and smg traffic"
  vpc_id      = aws_vpc.vpc[0].id

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["172.16.0.0/16"]
  }

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    from_port   = "4500"
    to_port     = "4500"
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
} 

resource "aws_internet_gateway" "gateway" {
  vpc_id  = aws_vpc.vpc[0].id
  tags    = local.common_tags
}

resource "aws_route_table" "rt" {
  for_each  = { for k in var.vpc_subnets: k.availability_zone => k }
  vpc_id    = aws_vpc.vpc[0].id
  tags      = local.common_tags
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
} 

resource "aws_route_table_association" "rta" {
  for_each  = { for k in var.vpc_subnets: k.availability_zone => k }
  subnet_id      = aws_subnet.slo[each.key].id
  route_table_id = aws_route_table.rt[each.key].id
} 

resource "aws_lb" "nlb" {
  tags                             = local.common_tags
  name                             = format("%s-nlb", var.f5xc_cluster_name)
  subnets                          = [ for subnet in aws_subnet.slo : subnet.id ]
  internal                         = true
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true

  timeouts {
    create = "35m"
    delete = "35m"
  }
}

resource "aws_lb_target_group" "controllers" {
  tags        = local.common_tags
  name        = format("%s-lb-ctl", var.f5xc_cluster_name)
  vpc_id      = aws_vpc.vpc[0].id
  target_type = "instance"
  protocol    = "TCP"
  port        = 6443

  health_check {
    protocol            = "TCP"
    port                = 6443
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 10
  }
}

resource "aws_lb_listener" "api_server" {
  tags              = local.common_tags
  port              = "6443"
  protocol          = "TCP"
  load_balancer_arn = aws_lb.nlb.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.controllers.arn
  }
}

