## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "oci_containerengine_cluster_option" "test_cluster_option" {
  cluster_option_id = "all"
}

data "oci_containerengine_node_pool_option" "test_node_pool_option" {
  node_pool_option_id = "all"
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

data "oci_limits_services" "test_services" {
  compartment_id = var.tenancy_ocid

  filter {
    name   = "name"
    values = ["compute"]
  }
}

data "oci_limits_limit_values" "test_limit_values" {
  count          = length(data.oci_identity_availability_domains.ADs.availability_domains)
  compartment_id = var.tenancy_ocid
  service_name   = data.oci_limits_services.test_services.services.0.name

  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[count.index].name
  name                = "vm-standard-e2-1-micro-count"
  scope_type          = "AD"
}
