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

resource "volterra_voltstack_site" "cluster" {
  depends_on  = [ module.aws1 ]
  name        = format("%s-aws1", var.project_prefix)
  namespace   = "system"

  no_bond_devices = true
  disable_gpu     = true

  k8s_cluster {
    namespace = "system"
    name      = volterra_k8s_cluster.cluster.name
  }

  master_nodes = [ for node in module.aws1.appstack.master : split(".", node.private_dns)[0] ]
  worker_nodes = [ for node in module.aws1.appstack.worker : split(".", node.private_dns)[0] ]

  logs_streaming_disabled = true
  default_network_config  = true
  default_storage_config  = true
  deny_all_usb            = true
  volterra_certified_hw   = "aws-byol-voltstack-combo"
}

resource "volterra_registration_approval" "master" {
  depends_on   = [volterra_voltstack_site.cluster]
  for_each     = toset([for node in module.aws1.appstack.master : split(".", node.private_dns)[0]])
  cluster_name = volterra_voltstack_site.cluster.name
  cluster_size = var.master_nodes_count
  hostname     = each.key
  wait_time    = var.f5xc_registration_wait_time
  retry        = var.f5xc_registration_retry
}

resource "volterra_registration_approval" "worker" {
  depends_on   = [volterra_voltstack_site.cluster]
  for_each     = toset([for node in module.aws1.appstack.worker : split(".", node.private_dns)[0]])
  cluster_name = volterra_voltstack_site.cluster.name
  cluster_size = var.master_nodes_count
  hostname     = each.key
  wait_time    = var.f5xc_registration_wait_time
  retry        = var.f5xc_registration_retry
}

# do I need decommission for appstack nodes?
#resource "volterra_site_state" "decommission_when_delete" {
#  depends_on = [volterra_registration_approval.master]
#  name       = var.f5xc_node_name
#  when       = "delete"
#  state      = "DECOMMISSIONING"
#  wait_time  = var.f5xc_registration_wait_time
#  retry      = var.f5xc_registration_retry
#}
