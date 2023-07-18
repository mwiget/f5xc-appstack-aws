module "appstack" {
  source                = "./appstack/aws"
  f5xc_tenant           = var.f5xc_tenant
  f5xc_api_url          = var.f5xc_api_url
  f5xc_namespace        = var.f5xc_namespace
  f5xc_api_token        = var.f5xc_api_token
  f5xc_api_ca_cert      = var.f5xc_api_ca_cert
  owner_tag             = var.owner
  has_public_ip         = true
  is_sensitive          = false
  f5xc_cluster_name     = format("%s-aws1", var.project_prefix)
  f5xc_cluster_labels   = { "site-mesh" : format("%s", var.project_prefix) }
  master_nodes_count    = var.master_nodes_count
  worker_nodes_count    = var.worker_nodes_count
  f5xc_cluster_latitude = 59
  f5xc_cluster_longitude = 18
  instance_type_master  = "t3.xlarge"
  instance_type_worker  = "t3.xlarge"
  aws_vpc_cidr_block    = "192.168.0.0/20"
  f5xc_aws_region       = "eu-north-1"
  vpc_subnets           = [
    { availability_zone = "a", cidr_block = "192.168.1.0/24" },
    { availability_zone = "b", cidr_block = "192.168.2.0/24" },
    { availability_zone = "c", cidr_block = "192.168.3.0/24" }
  ]
  providers = {
    aws = aws.eu-north-1
  }
  ssh_public_key        = file(var.ssh_public_key_file)
}

output "appstack" {
  value = module.appstack
}

