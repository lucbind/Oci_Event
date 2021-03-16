## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Gets a list of Availability Domains

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

# Get the latest Oracle Linux image
data "oci_core_images" "InstanceImageOCID" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}