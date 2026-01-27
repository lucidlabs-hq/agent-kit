# =============================================================================
# Agent Kit - Docker Compose Template (Terraform)
#
# This template is used by Terraform to generate the docker-compose.yml
# for Elestio deployment.
# =============================================================================

services:
  caddy:
    image: caddy:2-alpine
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config
    environment:
      - DOMAIN=${domain}
      - ACME_EMAIL=${acme_email}
    depends_on:
      - frontend
    networks:
      - agent-network

  frontend:
    build:
      context: ./frontend
    restart: unless-stopped
    environment:
      - NODE_ENV=production
      - NEXT_PUBLIC_CONVEX_URL=${convex_url}
      - NEXT_PUBLIC_MASTRA_URL=http://mastra:4000
    depends_on:
      - mastra
    networks:
      - agent-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  mastra:
    build:
      context: ./mastra
    restart: unless-stopped
    environment:
      - NODE_ENV=production
      - PORT=4000
      - ANTHROPIC_API_KEY=${anthropic_api_key}
      - OPENAI_API_KEY=${openai_api_key}
      - CONVEX_URL=${convex_url}
    networks:
      - agent-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:4000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

%{ if n8n_enabled }
  n8n:
    image: n8nio/n8n:latest
    restart: unless-stopped
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=${n8n_user}
      - N8N_BASIC_AUTH_PASSWORD=${n8n_password}
      - N8N_HOST=${domain}
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - WEBHOOK_URL=https://${domain}/n8n/
      - GENERIC_TIMEZONE=Europe/Berlin
    volumes:
      - n8n_data:/home/node/.n8n
      - ./n8n/workflows:/home/node/workflows:ro
    networks:
      - agent-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5678/healthz"]
      interval: 30s
      timeout: 10s
      retries: 3
%{ endif }

networks:
  agent-network:
    driver: bridge

volumes:
  caddy_data:
  caddy_config:
%{ if n8n_enabled }
  n8n_data:
%{ endif }
