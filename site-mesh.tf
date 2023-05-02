resource "volterra_virtual_site" "vs" {
  name      = format("%s-vsphere", var.project_prefix)
  namespace = "shared"

  site_selector {
    expressions = [ format("site-mesh in (%s)", var.project_prefix) ]
  }

  site_type = "CUSTOMER_EDGE"
}

resource "volterra_site_mesh_group" "smg" {
  name        = format("%s-vsphere", var.project_prefix)
  namespace   = "system"
  type        = "SITE_MESH_GROUP_TYPE_FULL_MESH"
  virtual_site {
    name = volterra_virtual_site.vs.name
    namespace = "shared"
  }
}
