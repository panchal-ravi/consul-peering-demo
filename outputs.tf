output "consul-dc1-server-fqdn" {
  description = "Consul DC #1 Server"
  value       = "https://${module.consul-dc1-server.ui_public_fqdn}"
}

output "consul-dc2-server-fqdn" {
  description = "Consul DC #2 Server"
  value       = "https://${module.consul-dc2-server.ui_public_fqdn}"
}

output "deployment_id" {
  value = local.deployment_id
}
