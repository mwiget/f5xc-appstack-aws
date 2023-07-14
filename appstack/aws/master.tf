resource "aws_instance" "master" {
  count                   = var.master_nodes_count
  ami                     = var.f5xc_ce_machine_image["voltstack"][var.f5xc_aws_region]
  instance_type           = var.instance_type_master
  iam_instance_profile    = aws_iam_instance_profile.instance_profile.id
  user_data               = templatefile("./appstack/aws/templates/cloud_init.yaml", {
    site_token        = volterra_token.site.id,
    cluster_name      = var.f5xc_cluster_name,
    vp_manager_config = base64encode(local.vpm_config),
    ssh_public_key    = var.ssh_public_key
  })
  vpc_security_group_ids      = [
    resource.aws_security_group.allow_traffic.id
  ]
  subnet_id                   = [for subnet in aws_subnet.slo : subnet.id][count.index % length(aws_subnet.slo)]
  source_dest_check           = false
  associate_public_ip_address = true

  root_block_device {
    volume_size = 40
  }
  
  tags = {
    Name    = format("%s-m%s", var.f5xc_cluster_name, count.index)
    Creator = var.owner_tag
    "kubernetes.io/cluster/${var.f5xc_cluster_name}"  = "owned"
  }
}

resource "aws_lb_target_group_attachment" "volterra_ce_attachment" {
  count            = var.master_nodes_count == 3 ? 3 : 0
  target_group_arn = aws_lb_target_group.controllers.id
  target_id        = aws_instance.master[count.index].id
  port             = 6443
}

