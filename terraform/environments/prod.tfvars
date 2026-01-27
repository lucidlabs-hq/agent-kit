# =============================================================================
# Production Environment Configuration
# =============================================================================

# Server Configuration
server_name   = "agent-kit-prod"
server_type   = "MEDIUM-2C-4G"
provider_name = "hetzner"
datacenter    = "fsn1"  # Falkenstein, Germany (EU GDPR compliant)

# Domain
domain     = "agent-kit.example.com"
acme_email = "admin@example.com"

# Features
n8n_enabled = true
enable_ssh  = false

# NOTE: Sensitive values should be provided via:
# - Environment variables: TF_VAR_anthropic_api_key
# - Terraform Cloud variables
# - Secure secrets manager
