# =============================================================================
# Development Environment Configuration
# =============================================================================

# Server Configuration
server_name   = "agent-kit-dev"
server_type   = "SMALL-1C-2G"
provider_name = "hetzner"
datacenter    = "fsn1"

# Domain (use staging subdomain)
domain     = "dev.agent-kit.example.com"
acme_email = "dev@example.com"

# Features
n8n_enabled = false
enable_ssh  = true

# NOTE: Sensitive values should be provided via:
# - Environment variables: TF_VAR_anthropic_api_key
# - Terraform Cloud variables
# - Secure secrets manager
