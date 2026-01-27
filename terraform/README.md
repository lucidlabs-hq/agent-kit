# Terraform Infrastructure

Infrastructure as Code for deploying Agent Kit to Elestio.

## Overview

This Terraform configuration deploys:
- **Caddy** - Reverse proxy with auto HTTPS
- **Frontend** - Next.js application
- **Mastra** - AI agent server
- **n8n** (optional) - Workflow automation

## Prerequisites

1. [Terraform](https://terraform.io) >= 1.5.0
2. [Elestio account](https://elestio.com)
3. Domain with DNS access

## Setup

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

### 2. Configure Variables

Create a `terraform.tfvars` file or use environment variables:

```bash
# Required
export TF_VAR_elestio_email="your@email.com"
export TF_VAR_elestio_api_token="your-api-token"
export TF_VAR_project_id="your-project-id"
export TF_VAR_domain="your-domain.com"
export TF_VAR_anthropic_api_key="sk-ant-..."
export TF_VAR_convex_url="https://your-project.convex.cloud"

# Optional
export TF_VAR_openai_api_key="sk-..."
export TF_VAR_n8n_password="secure-password"
```

### 3. Plan Deployment

```bash
# Development
terraform plan -var-file=environments/dev.tfvars

# Production
terraform plan -var-file=environments/prod.tfvars
```

### 4. Apply

```bash
# Development
terraform apply -var-file=environments/dev.tfvars

# Production
terraform apply -var-file=environments/prod.tfvars
```

## Project Structure

```
terraform/
├── main.tf              # Main configuration
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── templates/
│   └── docker-compose.yml.tpl  # Docker Compose template
├── environments/
│   ├── dev.tfvars       # Development settings
│   └── prod.tfvars      # Production settings
└── README.md
```

## Server Sizes

| Size | vCPU | RAM | Use Case |
|------|------|-----|----------|
| SMALL-1C-2G | 1 | 2GB | Development |
| MEDIUM-2C-4G | 2 | 4GB | Production |
| LARGE-4C-8G | 4 | 8GB | High traffic |

## Datacenter Locations

| Code | Location | Notes |
|------|----------|-------|
| fsn1 | Falkenstein, DE | EU GDPR compliant |
| nbg1 | Nuremberg, DE | EU GDPR compliant |
| hel1 | Helsinki, FI | EU GDPR compliant |
| ash | Ashburn, US | US East |

## DNS Configuration

After deployment, configure your DNS:

```
A     @     <server-ipv4>
A     www   <server-ipv4>
AAAA  @     <server-ipv6>
AAAA  www   <server-ipv6>
```

Terraform outputs will show the IP addresses.

## Outputs

| Output | Description |
|--------|-------------|
| `application_url` | Main application URL |
| `n8n_url` | n8n dashboard URL |
| `server_ipv4` | Server IPv4 address |
| `server_ipv6` | Server IPv6 address |
| `ssh_connection` | SSH connection string |
| `elestio_dashboard` | Elestio dashboard link |

## Maintenance

### Update Deployment

```bash
# Pull latest changes
git pull

# Re-apply Terraform
terraform apply -var-file=environments/prod.tfvars
```

### View Logs

```bash
# SSH into server (if enabled)
ssh root@<server-ip>

# View logs
docker-compose logs -f
docker-compose logs -f frontend
docker-compose logs -f mastra
```

### Destroy

```bash
terraform destroy -var-file=environments/prod.tfvars
```

## Security Notes

1. **Secrets** - Never commit sensitive values to Git
2. **SSH** - Disable SSH in production or restrict CIDR
3. **n8n** - Use strong password, consider IP whitelist
4. **Backup** - Configure regular backups in Elestio

## Troubleshooting

### Certificate Issues

Caddy handles certificates automatically. If issues occur:
1. Check domain DNS propagation
2. Verify port 80/443 are open
3. Check Caddy logs: `docker-compose logs caddy`

### Health Check Failures

```bash
# Check service health
docker-compose ps

# Check specific service
docker-compose logs frontend
docker-compose logs mastra
```

### Resource Limits

If services are slow or crashing:
1. Check server metrics in Elestio dashboard
2. Consider upgrading server size
3. Review container resource limits
