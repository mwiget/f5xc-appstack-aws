output "appstack" {
  value = {
    vpc_id        = var.aws_existing_vpc_id != "" ? var.aws_existing_vpc_id : null
    slo           = aws_subnet.slo
    master        = aws_instance.master
    master_nodes  = [ for node in aws_instance.master : split(".", node.private_dns)[0] ]
    worker        = aws_instance.worker
    worker_nodes  = [ for node in aws_instance.worker : split(".", node.private_dns)[0] ]
    subnet_ids    = [ for subnet in aws_subnet.slo : subnet.id ]
    gateway       = aws_internet_gateway.gateway
    nlb           = aws_lb.nlb
    security_group = resource.aws_security_group.allow_traffic
    iam    = {
      role             = aws_iam_role.role
      policy           = aws_iam_policy.policy
      attachment       = aws_iam_role_policy_attachment.attachment
      instance_profile = aws_iam_instance_profile.instance_profile
    }
    ssh_key = aws_key_pair.aws_key
    #    nlb     = length(var.f5xc_aws_vpc_az_nodes) == 3 ? {
    #      nlb = module.network_nlb[0].nlb
    #    } : null
  }
}