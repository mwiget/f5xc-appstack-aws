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

resource "restapi_object" "appstack_site_1" {
  id_attribute = "metadata/name"
  path         = "/config/namespaces/system/voltstack_sites"
  data         = local.aws1
}

module "aws1" {
  depends_on     = [restapi_object.appstack_site_1]
  source         = "./modules/f5xc/ce/aws"
  f5xc_tenant    = var.f5xc_tenant
  f5xc_api_url   = var.f5xc_api_url
  f5xc_namespace = var.f5xc_namespace
  f5xc_api_token = var.f5xc_api_token
  f5xc_api_ca_cert = var.f5xc_api_ca_cert
  maurice_endpoint      = var.maurice_endpoint
  maurice_mtls_endpoint = var.maurice_mtls_endpoint
  owner_tag          = var.owner
  has_public_ip      = true
  is_sensitive       = false
  aws_vpc_cidr_block = "192.168.0.0/20"
  f5xc_aws_vpc_az_nodes = {
    node0 = {
      f5xc_aws_vpc_slo_subnet = "192.168.0.0/26",
      f5xc_aws_vpc_az_name    = format("%s%s", "eu-south-1", "a")
    },
    node1 = {
      f5xc_aws_vpc_slo_subnet = "192.168.0.64/26",
      f5xc_aws_vpc_az_name    = format("%s%s", "eu-south-1", "b")
    },
    node2 = {
      f5xc_aws_vpc_slo_subnet = "192.168.0.128/26",
      f5xc_aws_vpc_az_name    = format("%s%s", "eu-south-1", "c")
    }
  }
  aws_security_group_rules_slo_ingress = []
  aws_security_group_rules_slo_egress  = []
  f5xc_ce_gateway_type                 = "voltstack"
  f5xc_token_name                      = format("%s-aws1", var.project_prefix)
  f5xc_aws_region                      = "eu-south-1"
  f5xc_cluster_latitude                = "45.4"
  f5xc_cluster_longitude               = "9.18"
  f5xc_cluster_name                    = format("%s-aws1", var.project_prefix)
  f5xc_cluster_labels                  = { "site-mesh" : format("%s", var.project_prefix) }
  ssh_public_key                       = file(var.ssh_public_key_file)
  providers = {
    aws = aws.eu-south-1
  }
}

locals {
  aws1 = jsonencode(
    {
      "metadata" : {
        "name" : format("%s-aws1", var.project_prefix),
        "namespace" : "system",
        "labels" : {
          "site-mesh" : var.project_prefix
        },
        "annotations" : {},
        "description" : "",
        "disable" : false
      },
      "spec" : {
        "volterra_certified_hw" : "aws-byol-voltstack-combo",
        "master_nodes" : [
          format("%s-aws1-node0", var.project_prefix),
          format("%s-aws1-node1", var.project_prefix),
          format("%s-aws1-node2", var.project_prefix)
        ],
        "worker_nodes" : [],
        "no_bond_devices" : {},
        "default_network_config" : {},
        "default_storage_config" : {},
        "disable_gpu" : {},
        "coordinates" : {
          "latitude" : 45.4,
          "longitude" : 9.18
        },
        "k8s_cluster" : {
          "namespace" : "system",
          "name" : volterra_k8s_cluster.cluster.name,
          "kind" : "k8s_cluster"
        },
        "logs_streaming_disabled" : {},
        "allow_all_usb" : {},
        "enable_vm" : {},
        "default_blocked_services" : {},
        "sw" : {
          "default_sw_version" : {}
        },
        "os" : {
          "default_os_version" : {}
        },
        "offline_survivability_mode" : {
          "enable_offline_survivability_mode" : {}
        }
      }
    }
  )
}

output "appstack_site_1" {
  value = restapi_object.appstack_site_1.api_response
}

output "aws1" {
  value = module.aws1
}
