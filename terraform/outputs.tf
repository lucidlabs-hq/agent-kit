# =============================================================================
# Agent Kit - Terraform Outputs
# =============================================================================

output "application_url" {
  description = "URL of the deployed application"
  value       = "https://${var.domain}"
}

output "n8n_url" {
  description = "URL of n8n dashboard (if enabled)"
  value       = var.n8n_enabled ? "https://${var.domain}/n8n/" : "n8n not enabled"
}

output "server_ipv4" {
  description = "IPv4 address of the server"
  value       = elestio_custom.agent_kit.ipv4
}

output "server_ipv6" {
  description = "IPv6 address of the server"
  value       = elestio_custom.agent_kit.ipv6
}

output "ssh_connection" {
  description = "SSH connection string"
  value       = var.enable_ssh ? "ssh root@${elestio_custom.agent_kit.ipv4}" : "SSH access disabled"
}

output "elestio_dashboard" {
  description = "Link to Elestio dashboard"
  value       = "https://dash.elestio.io/projects/${var.project_id}/services/${elestio_custom.agent_kit.id}"
}
