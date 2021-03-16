## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

############################################
# VCN module
############################################

module "vcn" {
  source = "./modules/vcn"
  tenancy_ocid          = var.tenancy_ocid
  compartment_ocid      = var.compartment_ocid
}


############################################
# TLS module
############################################

module "tls" {
  source = "./modules/tls"
}


############################################
# jenkins master module
############################################

module "jenkins-master" {
  source                = "./modules/jenkins-master"
  tenancy_ocid          = var.tenancy_ocid
  compartment_ocid      = var.compartment_ocid
  instance_shape        = var.instance_shape
  subnet_id             = module.vcn.subnet1_ocid
  jenkins_version       = var.jenkins_version
  jenkins_password      = var.jenkins_password
  http_port             = var.http_port
  plugins               = var.plugins
  instance_os           = var.instance_os
  linux_os_version      = var.linux_os_version
  ssh_public_key        = module.tls.ssh_public_key
  ssh_private_key       = module.tls.ssh_private_key
  jnlp_port             = var.jnlp_port
}

############################################
# K8S module
############################################

module "k8s" {
  source                = "./modules/k8s"
  tenancy_ocid          = var.tenancy_ocid
  compartment_ocid      = var.compartment_ocid
  vcn                   = module.vcn.vcn_id
  clustersub1_id        = module.vcn.subnet1_ocid
  nodesub1_id           = module.vcn.subnet2_ocid
  ssh_public_key        = module.tls.ssh_public_key
} 
