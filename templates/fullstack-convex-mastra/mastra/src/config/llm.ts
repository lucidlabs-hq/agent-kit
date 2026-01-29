/**
 * LLM Configuration
 *
 * Supports multiple environments:
 * - Local: Ollama (phi3:mini) for offline development
 * - Production: Portkey Gateway → Claude Sonnet
 *
 * Created: 29. Januar 2026
 */

export interface LLMConfig {
  baseUrl: string;
  model: string;
  provider: string;
  maxTokens?: number;
}

const isProduction = process.env.NODE_ENV === 'production';

export const llmConfig: LLMConfig = {
  baseUrl: process.env.LLM_BASE_URL || 'http://localhost:11434/v1',
  model: process.env.LLM_MODEL || 'phi3:mini',
  provider: process.env.LLM_PROVIDER || 'ollama',
  maxTokens: 4096,
};

/**
 * Get LLM configuration for current environment
 */
export function getLLMConfig(): LLMConfig {
  if (isProduction) {
    return {
      baseUrl: process.env.LLM_BASE_URL || 'http://lucidlabs-portkey:8787/v1',
      model: process.env.LLM_MODEL || 'claude-sonnet-4-5-20250514',
      provider: process.env.LLM_PROVIDER || 'anthropic',
      maxTokens: 4096,
    };
  }

  // Development: Use Ollama for offline work
  return {
    baseUrl: process.env.LLM_BASE_URL || 'http://localhost:11434/v1',
    model: process.env.LLM_MODEL || 'phi3:mini',
    provider: process.env.LLM_PROVIDER || 'ollama',
    maxTokens: 4096,
  };
}

/**
 * Headers for Portkey Gateway (production only)
 */
export function getPortkeyHeaders(): Record<string, string> {
  if (!isProduction) return {};

  return {
    'x-portkey-api-key': process.env.PORTKEY_API_KEY || '',
    'x-portkey-provider': llmConfig.provider,
  };
}

export default llmConfig;
