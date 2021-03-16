output "ssh_private_key" {
  value = tls_private_key.public_private_key_pair.private_key_pem
}

output "ssh_public_key" {
  value = tls_private_key.public_private_key_pair.public_key_openssh
}