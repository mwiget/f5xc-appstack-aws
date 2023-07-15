locals {
  common_tags = {
    "kubernetes.io/cluster/${var.f5xc_cluster_name}" = "owned"
    "Owner"                                          = var.owner_tag
  }
  common_tags_worker = {
    "kubernetes.io/cluster/${var.f5xc_cluster_name}" = "owned"
    "Owner"                                          = var.owner_tag
    "deployment"                                     = var.f5xc_cluster_name
  }
  vpm_config = yamlencode({
    "Vpm" : {
      "ClusterName" : var.f5xc_cluster_name,
      "ClusterType" : "ce",
      "Token" : volterra_token.site.id,
      "MauricePrivateEndpoint" : module.maurice.endpoints.maurice_mtls,
      "MauriceEndpoint" : module.maurice.endpoints.maurice,
      "Labels" : var.f5xc_cluster_labels,
      "CertifiedHardwareEndpoint" : "https://vesio.blob.core.windows.net/releases/certified-hardware/aws.yml"
    }
    Kubernetes : {
      "EtcdUseTLS" : true
      "Server" : "vip"
    }
  })
  kubeconfig = format("./%s.kubeconfig", var.f5xc_cluster_name)
}
