## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "compartment_ocid" {}
variable "tenancy_ocid" {}
variable "vcn" {}
variable "ssh_public_key" {}

variable "oke_cluster" {
  type    = map
  default = {
    name           = "OKE_Cluster"
    pool_name      = "Node_Pool"
    node_shape     = "VM.Standard2.1"
    pods_cidr      = "10.1.0.0/16"
    services_cidr = "10.2.0.0/16"
  }
}

variable "clustersub1_id" {}
variable "cluster_options_add_ons_is_kubernetes_dashboard_enabled" {
  default = true
}
variable "cluster_options_add_ons_is_tiller_enabled" {
  default = true
}
variable "node_pool_initial_node_labels_key" {
  default = "key"
}
variable "node_pool_initial_node_labels_value" {
  default = "value"
}

variable "nodesub1_id" {}


