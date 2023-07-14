resource "aws_instance" "instance" {
  ami                  = var.aws_instance_image
  tags                 = local.common_tags
  key_name             = var.ssh_public_key_name
  monitoring           = var.aws_instance_monitoring
  instance_type        = var.aws_instance_type
  user_data_base64     = base64encode(var.f5xc_instance_config)
  iam_instance_profile = var.aws_iam_instance_profile_id

  root_block_device {
    volume_size = var.aws_instance_disk_size
  }

  network_interface {
    network_interface_id = var.aws_interface_slo_id
    device_index         = "0"
  }

  dynamic "network_interface" {
    for_each = var.is_multi_nic ? [1] : []
    content {
      network_interface_id = var.aws_interface_sli_id
      device_index         = "1"
    }
  }

  timeouts {
    create = var.aws_instance_create_timeout
    delete = var.aws_instance_delete_timeout
  }
}

resource "aws_lb_target_group_attachment" "volterra_ce_attachment" {
  count            = var.f5xc_cluster_size == 3 ? 1 : 0
  target_group_arn = var.aws_lb_target_group_arn
  target_id        = aws_instance.instance.id
  port             = 6443
}

