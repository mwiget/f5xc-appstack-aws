resource "volterra_k8s_cluster" "cluster" {
  name      = format("%s-aws1-k8s", var.project_prefix)
  namespace = "system"

  no_cluster_wide_apps              = true
  use_default_cluster_role_bindings = true

  use_default_cluster_roles = true

  cluster_scoped_access_permit = true
  global_access_enable         = true
  no_insecure_registries       = true

  local_access_config {
    local_domain = format("%s-aws1.local", var.project_prefix)
    default_port = true
  }
  use_default_psp = true
}

resource "volterra_voltstack_site" "voltstack1" {
  name      = format("%s-aws1", var.project_prefix)
  namespace = "system"

  no_bond_devices = true
  disable_gpu     = true

  k8s_cluster {
    namespace = "system"
    name      = volterra_k8s_cluster.cluster.name
  }

  master_nodes = formatlist("${var.project_prefix}-aws1-node%s", range(0,var.master_nodes_count))
  worker_nodes = var.worker_nodes_count > 0 ? formatlist("${var.project_prefix}-aws1-worker%s", range(0,var.worker_nodes_count)) : []

  logs_streaming_disabled = true
  default_network_config  = true
  default_storage_config  = true
  deny_all_usb            = true
  volterra_certified_hw   = "aws-byol-voltstack-combo"
}

module "aws1" {
  depends_on     = [volterra_voltstack_site.voltstack1]
  source         = "./modules/f5xc/ce/aws"
  f5xc_tenant    = var.f5xc_tenant
  f5xc_api_url   = var.f5xc_api_url
  f5xc_namespace = var.f5xc_namespace
  f5xc_api_token = var.f5xc_api_token
  f5xc_api_ca_cert = var.f5xc_api_ca_cert
  owner_tag          = var.owner
  has_public_ip      = true
  is_sensitive       = false
  aws_vpc_cidr_block = "192.168.0.0/20"
  f5xc_aws_vpc_az_nodes = {
    node0 = {
      f5xc_aws_vpc_slo_subnet = "192.168.0.0/26",
      f5xc_aws_vpc_az_name    = format("%s%s", "eu-north-1", "a")
    },
    node1 = {
      f5xc_aws_vpc_slo_subnet = "192.168.0.64/26",
      f5xc_aws_vpc_az_name    = format("%s%s", "eu-north-1", "b")
    },
    node2 = {
      f5xc_aws_vpc_slo_subnet = "192.168.0.128/26",
      f5xc_aws_vpc_az_name    = format("%s%s", "eu-north-1", "c")
    },
    worker0 = {
      f5xc_aws_vpc_slo_subnet = "192.168.1.0/26",
      f5xc_aws_vpc_az_name    = format("%s%s", "eu-north-1", "a")
    },
    worker1 = {
      f5xc_aws_vpc_slo_subnet = "192.168.1.64/26",
      f5xc_aws_vpc_az_name    = format("%s%s", "eu-north-1", "b")
    }
  }
  aws_security_group_rules_slo_ingress = []
  aws_security_group_rules_slo_egress  = []
  f5xc_ce_gateway_type                 = "voltstack"
  f5xc_token_name                      = format("%s-aws1", var.project_prefix)
  f5xc_aws_region                      = "eu-north-1"
  f5xc_cluster_latitude                = "45.4"
  f5xc_cluster_longitude               = "9.18"
  f5xc_cluster_name                    = format("%s-aws1", var.project_prefix)
  f5xc_cluster_labels                  = { "site-mesh" : format("%s", var.project_prefix) }
  ssh_public_key                       = file(var.ssh_public_key_file)
  providers = {
    aws = aws.eu-north-1
  }
}

output "appstack_site_1" {
  value = volterra_voltstack_site.voltstack1
}

output "aws1" {
  value = module.aws1
}

output "aws1_vpc_id" {
  value = module.aws1.ce.nodes.node0.network.common.vpc.id 
}
