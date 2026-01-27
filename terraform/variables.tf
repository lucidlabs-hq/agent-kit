# =============================================================================
# Agent Kit - Terraform Variables
# =============================================================================

# =============================================================================
# ELESTIO CREDENTIALS
# =============================================================================

variable "elestio_email" {
  description = "Elestio account email"
  type        = string
  sensitive   = true
}

variable "elestio_api_token" {
  description = "Elestio API token"
  type        = string
  sensitive   = true
}

# =============================================================================
# PROJECT CONFIGURATION
# =============================================================================

variable "project_id" {
  description = "Elestio project ID"
  type        = string
}

variable "server_name" {
  description = "Name of the server"
  type        = string
  default     = "agent-kit"
}

variable "server_type" {
  description = "Server type/size (e.g., SMALL-1C-2G, MEDIUM-2C-4G)"
  type        = string
  default     = "SMALL-1C-2G"
}

variable "provider_name" {
  description = "Cloud provider (hetzner, digitalocean, aws, etc.)"
  type        = string
  default     = "hetzner"
}

variable "datacenter" {
  description = "Datacenter location"
  type        = string
  default     = "fsn1"  # Falkenstein, Germany (EU)
}

# =============================================================================
# DOMAIN & SSL
# =============================================================================

variable "domain" {
  description = "Domain name for the application"
  type        = string
}

variable "acme_email" {
  description = "Email for Let's Encrypt certificates"
  type        = string
}

# =============================================================================
# AI CONFIGURATION
# =============================================================================

variable "anthropic_api_key" {
  description = "Anthropic API key for Claude"
  type        = string
  sensitive   = true
}

variable "openai_api_key" {
  description = "OpenAI API key (optional)"
  type        = string
  default     = ""
  sensitive   = true
}

# =============================================================================
# DATABASE
# =============================================================================

variable "convex_url" {
  description = "Convex backend URL"
  type        = string
}

# =============================================================================
# N8N CONFIGURATION (Optional)
# =============================================================================

variable "n8n_enabled" {
  description = "Enable n8n workflow automation"
  type        = bool
  default     = false
}

variable "n8n_user" {
  description = "n8n basic auth username"
  type        = string
  default     = "admin"
}

variable "n8n_password" {
  description = "n8n basic auth password"
  type        = string
  sensitive   = true
  default     = ""
}

# =============================================================================
# SSH ACCESS
# =============================================================================

variable "enable_ssh" {
  description = "Enable SSH access to the server"
  type        = bool
  default     = false
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssh_public_keys" {
  description = "List of SSH public keys for access"
  type        = list(object({
    username   = string
    key_data   = string
  }))
  default     = []
}
