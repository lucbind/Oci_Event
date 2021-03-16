## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Default Variables

variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
# variable "user_ocid" {}
# variable "fingerprint" {}
# variable "private_key_path" {}

variable "jenkins_password" {}

variable "jenkins_version" {
    default     = "2.249.1"
}

variable "instance_shape" {
  description = "Instance Shape"
  default     = "VM.Standard2.16"
}

variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "7.9"
}

variable "http_port" {
  default     = 8080
}

variable "jnlp_port" {
  default = 49187
}

variable "plugins" {  
  type        = list
  description = "A list of Jenkins plugins to install, use short names. "
  default     = ["git", "ssh-slaves", "oracle-cloud-infrastructure-compute", "blueocean", "blueocean-github-pipeline"]
  }