## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "master_login_url" {
  value = "http://${module.jenkins-master.public_ip}:${var.http_port}"
}

output "generated_ssh_private_key" {
  value = module.tls.ssh_private_key
}