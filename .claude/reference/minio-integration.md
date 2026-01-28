# MinIO Integration

> S3-kompatible Object Storage für Dateiverarbeitung

## Overview

MinIO ist ein S3-kompatibler Object Store, der sich perfekt für Elestio-Deployments eignet. Wir nutzen ihn für:

- **Dokumentenverarbeitung** (PDF, Bilder, etc.)
- **Agent Artefakte** (generierte Dateien)
- **Report Storage** (Customer Reports)
- **Backup & Archive**

```
┌─────────────────────────────────────────────────────────────────────┐
│                      FILE STORAGE ARCHITECTURE                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   CONVEX                    MINIO                   EXTERNAL         │
│   (Metadata)                (Files)                 (Delivery)       │
│                                                                      │
│   ┌───────────┐            ┌───────────┐           ┌───────────┐    │
│   │ Documents │            │ Buckets   │           │ Presigned │    │
│   │ table     │───────────►│           │──────────►│ URLs      │    │
│   │           │  file_key  │ /reports  │           │           │    │
│   │ file_key  │            │ /uploads  │           │ Customer  │    │
│   │ metadata  │            │ /exports  │           │ Download  │    │
│   └───────────┘            └───────────┘           └───────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## MCP Server (Claude Integration)

### Offizieller MinIO MCP Server

MinIO bietet einen offiziellen MCP Server für Claude-Integration:

```bash
# MCP Server hinzufügen
claude mcp add minio-server -- npx -y @minio/mcp-server-aistor

# Oder Python-Version
claude mcp add minio-server -- python -m minio_mcp_server.server
```

### Konfiguration

In `~/.claude/settings.json` oder projekt-spezifisch:

```json
{
  "mcpServers": {
    "minio": {
      "command": "npx",
      "args": ["-y", "@minio/mcp-server-aistor"],
      "env": {
        "MINIO_ENDPOINT": "minio.example.com",
        "MINIO_ACCESS_KEY": "your-access-key",
        "MINIO_SECRET_KEY": "your-secret-key",
        "MINIO_USE_SSL": "true"
      }
    }
  }
}
```

### Verfügbare MCP Tools

| Tool | Funktion |
|------|----------|
| `list_buckets` | Alle Buckets auflisten |
| `list_bucket_contents` | Objekte in Bucket auflisten |
| `get_object` | Datei herunterladen |
| `put_object` | Datei hochladen |
| `create_bucket` | Neuen Bucket erstellen |
| `delete_object` | Datei löschen |

---

## Node.js SDK Integration

### Installation

```bash
pnpm add minio
# oder AWS SDK (S3-kompatibel)
pnpm add @aws-sdk/client-s3
```

### MinIO Native SDK

```typescript
// lib/minio.ts
import * as Minio from 'minio';

export const minioClient = new Minio.Client({
  endPoint: process.env.MINIO_ENDPOINT!,
  port: parseInt(process.env.MINIO_PORT || '9000'),
  useSSL: process.env.MINIO_USE_SSL === 'true',
  accessKey: process.env.MINIO_ACCESS_KEY!,
  secretKey: process.env.MINIO_SECRET_KEY!,
});

// Upload file
export async function uploadFile(
  bucket: string,
  fileName: string,
  buffer: Buffer,
  contentType: string
): Promise<string> {
  await minioClient.putObject(bucket, fileName, buffer, buffer.length, {
    'Content-Type': contentType,
  });
  return fileName;
}

// Generate presigned URL for download
export async function getPresignedUrl(
  bucket: string,
  fileName: string,
  expirySeconds = 3600
): Promise<string> {
  return minioClient.presignedGetObject(bucket, fileName, expirySeconds);
}

// List files in bucket
export async function listFiles(bucket: string, prefix?: string) {
  const objects: Minio.BucketItem[] = [];
  const stream = minioClient.listObjects(bucket, prefix, true);

  return new Promise<Minio.BucketItem[]>((resolve, reject) => {
    stream.on('data', (obj) => objects.push(obj));
    stream.on('error', reject);
    stream.on('end', () => resolve(objects));
  });
}
```

### AWS SDK (S3-kompatibel)

```typescript
// lib/s3-client.ts
import { S3Client, PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

export const s3Client = new S3Client({
  endpoint: process.env.MINIO_ENDPOINT,
  region: 'us-east-1', // MinIO ignoriert Region
  credentials: {
    accessKeyId: process.env.MINIO_ACCESS_KEY!,
    secretAccessKey: process.env.MINIO_SECRET_KEY!,
  },
  forcePathStyle: true, // Wichtig für MinIO!
});

export async function uploadToS3(
  bucket: string,
  key: string,
  body: Buffer,
  contentType: string
) {
  const command = new PutObjectCommand({
    Bucket: bucket,
    Key: key,
    Body: body,
    ContentType: contentType,
  });
  return s3Client.send(command);
}
```

---

## Bucket Structure

### Empfohlene Bucket-Organisation

```
minio/
├── lucidlabs-uploads/          # Temporäre Uploads
│   └── {session-id}/
│       └── {filename}
│
├── lucidlabs-reports/          # Customer Reports
│   └── {customer-slug}/
│       └── {year-month}/
│           └── report-{date}.pdf
│
├── lucidlabs-exports/          # Daten-Exporte
│   └── {customer-slug}/
│       └── {export-type}/
│           └── export-{timestamp}.json
│
├── lucidlabs-agents/           # Agent Artefakte
│   └── {agent-id}/
│       └── {session-id}/
│           └── {artifact-name}
│
└── lucidlabs-backups/          # System Backups
    └── {date}/
        └── {backup-type}.tar.gz
```

### Bucket Policies

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"AWS": ["arn:aws:iam:::user/app-user"]},
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": ["arn:aws:s3:::lucidlabs-uploads/*"]
    }
  ]
}
```

---

## Elestio Deployment

### Docker Compose (für lokale Entwicklung)

```yaml
# docker-compose.yml
services:
  minio:
    image: minio/minio:latest
    container_name: minio
    ports:
      - "9000:9000"   # API
      - "9001:9001"   # Console
    environment:
      MINIO_ROOT_USER: ${MINIO_ROOT_USER:-minioadmin}
      MINIO_ROOT_PASSWORD: ${MINIO_ROOT_PASSWORD:-minioadmin}
    volumes:
      - minio_data:/data
    command: server /data --console-address ":9001"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3

volumes:
  minio_data:
```

### Elestio Service

1. **Elestio Dashboard** → New Service → MinIO
2. **Konfiguration:**
   - Region: EU (GDPR)
   - Size: Nach Bedarf (ab 1 vCPU / 1GB RAM)
   - Storage: Nach Bedarf
3. **Credentials** → In `.env` speichern

### Terraform (Elestio)

```hcl
# terraform/minio.tf
resource "elestio_minio" "main" {
  project_id    = elestio_project.main.id
  server_name   = "minio-${var.environment}"
  server_type   = "SMALL-1C-2G"
  version       = "latest"

  provider_name = var.cloud_provider
  datacenter    = var.datacenter

  admin_email   = var.admin_email
}

output "minio_endpoint" {
  value = elestio_minio.main.cname
}
```

---

## Environment Variables

```env
# MinIO Configuration
MINIO_ENDPOINT=minio.example.com
MINIO_PORT=9000
MINIO_USE_SSL=true
MINIO_ACCESS_KEY=your-access-key
MINIO_SECRET_KEY=your-secret-key

# Buckets
MINIO_BUCKET_UPLOADS=lucidlabs-uploads
MINIO_BUCKET_REPORTS=lucidlabs-reports
MINIO_BUCKET_EXPORTS=lucidlabs-exports
```

---

## Use Cases

### 1. Report Generation

```typescript
// Generiere PDF Report → Speichere in MinIO
const pdfBuffer = await generateCustomerReport(customerId);
const fileName = `${customerSlug}/${getYearMonth()}/report-${getDate()}.pdf`;

await uploadFile('lucidlabs-reports', fileName, pdfBuffer, 'application/pdf');

// Presigned URL für Customer Portal
const downloadUrl = await getPresignedUrl('lucidlabs-reports', fileName, 86400);
```

### 2. Document Processing

```typescript
// Upload → Process → Store Result
const uploadKey = `${sessionId}/${file.name}`;
await uploadFile('lucidlabs-uploads', uploadKey, file.buffer, file.type);

// Agent verarbeitet Dokument...
const result = await agent.processDocument(uploadKey);

// Ergebnis speichern
await uploadFile('lucidlabs-exports', resultKey, resultBuffer, 'application/json');
```

### 3. Agent Artifacts

```typescript
// Agent speichert generierte Dateien
const artifactKey = `${agentId}/${sessionId}/${artifactName}`;
await uploadFile('lucidlabs-agents', artifactKey, artifactBuffer, contentType);
```

---

## Integration mit Convex

### Schema Extension

```typescript
// convex/schema.ts
export default defineSchema({
  documents: defineTable({
    name: v.string(),
    minio_bucket: v.string(),
    minio_key: v.string(),
    content_type: v.string(),
    size: v.number(),
    uploaded_by: v.id("users"),
    customer_id: v.optional(v.string()),
    metadata: v.optional(v.object({})),
  }).index("by_customer", ["customer_id"]),
});
```

### Convex Action für Upload

```typescript
// convex/documents.ts
export const getUploadUrl = action({
  args: { filename: v.string(), contentType: v.string() },
  handler: async (ctx, args) => {
    const key = `uploads/${Date.now()}-${args.filename}`;
    const presignedUrl = await getPresignedUploadUrl('lucidlabs-uploads', key);

    return { uploadUrl: presignedUrl, key };
  },
});
```

---

## Security Best Practices

1. **Separate Access Keys** pro Umgebung (dev/staging/prod)
2. **Bucket Policies** für least-privilege access
3. **Presigned URLs** mit kurzer Expiry für Downloads
4. **SSL/TLS** immer aktivieren
5. **Keine public Buckets** außer explizit benötigt
6. **Lifecycle Rules** für automatische Cleanup

---

## Referenzen

- [MinIO JavaScript SDK](https://github.com/minio/minio-js)
- [MinIO MCP Server](https://github.com/minio/mcp-server-aistor)
- [Elestio MinIO](https://elest.io/open-source/minio)
- [MinIO Documentation](https://min.io/docs/minio/linux/index.html)
