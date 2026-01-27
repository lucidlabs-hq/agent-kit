# =============================================================================
# Agent Kit - Terraform Main Configuration
#
# Infrastructure as Code for Elestio deployment.
#
# Usage:
#   cd terraform
#   terraform init
#   terraform plan -var-file=environments/prod.tfvars
#   terraform apply -var-file=environments/prod.tfvars
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    elestio = {
      source  = "elestio/elestio"
      version = "~> 0.17"
    }
  }

  # Optional: Configure remote state
  # backend "s3" {
  #   bucket = "your-terraform-state"
  #   key    = "agent-kit/terraform.tfstate"
  #   region = "eu-central-1"
  # }
}

# =============================================================================
# PROVIDER CONFIGURATION
# =============================================================================

provider "elestio" {
  email     = var.elestio_email
  api_token = var.elestio_api_token
}

# =============================================================================
# DATA SOURCES
# =============================================================================

# Get available server types
data "elestio_server_types" "available" {}

# =============================================================================
# RESOURCES
# =============================================================================

# Custom Docker service for Agent Kit
resource "elestio_custom" "agent_kit" {
  project_id    = var.project_id
  server_name   = var.server_name
  server_type   = var.server_type
  version       = "latest"
  provider_name = var.provider_name
  datacenter    = var.datacenter

  # Custom Docker configuration
  docker_compose_raw = templatefile("${path.module}/templates/docker-compose.yml.tpl", {
    domain            = var.domain
    acme_email        = var.acme_email
    anthropic_api_key = var.anthropic_api_key
    openai_api_key    = var.openai_api_key
    convex_url        = var.convex_url
    n8n_enabled       = var.n8n_enabled
    n8n_user          = var.n8n_user
    n8n_password      = var.n8n_password
  })

  # SSH access (optional)
  ssh_public_keys = var.ssh_public_keys

  # Firewall rules
  firewall_rules {
    protocol  = "tcp"
    port      = "443"
    cidr_ipv4 = "0.0.0.0/0"
  }

  firewall_rules {
    protocol  = "tcp"
    port      = "80"
    cidr_ipv4 = "0.0.0.0/0"
  }

  # Optional: SSH access
  dynamic "firewall_rules" {
    for_each = var.enable_ssh ? [1] : []
    content {
      protocol  = "tcp"
      port      = "22"
      cidr_ipv4 = var.ssh_allowed_cidr
    }
  }

  lifecycle {
    ignore_changes = [
      version,
    ]
  }
}

# =============================================================================
# OUTPUTS
# =============================================================================

output "service_url" {
  description = "URL of the deployed service"
  value       = "https://${var.domain}"
}

output "service_ip" {
  description = "IP address of the server"
  value       = elestio_custom.agent_kit.ipv4
  sensitive   = false
}

output "ssh_command" {
  description = "SSH command to access the server"
  value       = var.enable_ssh ? "ssh root@${elestio_custom.agent_kit.ipv4}" : "SSH disabled"
}
