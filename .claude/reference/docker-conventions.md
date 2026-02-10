# Docker Conventions

> Regeln für Docker-Container in Downstream-Projekten

---

## Problem

Wenn mehrere Projekte auf derselben Maschine entwickelt werden, kollidieren:
- Container-Namen (z.B. `convex-backend` existiert schon)
- Ports (z.B. `3210` ist bereits belegt)
- Volumes (Daten werden überschrieben)

---

## Lösung: Projekt-Präfix

Jedes Downstream-Projekt MUSS eindeutige Bezeichner verwenden.

### Namenskonvention

| Element | Format | Beispiel |
|---------|--------|----------|
| **Container** | `{prefix}-{service}` | `csr-convex-backend` |
| **Volume** | `{prefix}-{volume}` | `csr-convex-data` |
| **Network** | automatisch via compose | `client-service-reporting_default` |

### Präfix-Ableitung

Der Präfix wird aus dem Projektnamen abgeleitet:

| Projektname | Präfix |
|-------------|--------|
| `client-service-reporting` | `csr` |
| `invoice-accounting-assistant` | `iaa` |
| `casavi-sandbox-seeder` | `css` |
| `satellite` | `sat` |

**Regel:** Erste Buchstaben der Wörter, 2-4 Zeichen.

---

## Port-Zuordnung

Jedes Projekt bekommt einen Port-Offset:

| Projekt | Offset | Convex Backend | Convex Actions | Dashboard |
|---------|--------|----------------|----------------|-----------|
| Base (Template) | 0 | 3210 | 3211 | 6791 |
| satellite | +10 | 3220 | 3221 | 6792 |
| client-service-reporting | +2 | 3212 | 3213 | 6793 |
| invoice-accounting | +4 | 3214 | 3215 | 6794 |

### Port-Registry

Pflege eine Liste in `~/.claude-time/port-registry.json`:

```json
{
  "projects": {
    "lucidlabs-agent-kit": { "offset": 0, "prefix": "ak" },
    "satellite": { "offset": 10, "prefix": "sat" },
    "client-service-reporting": { "offset": 2, "prefix": "csr" }
  }
}
```

---

## docker-compose.dev.yml Template

```yaml
# =============================================================================
# {PROJECT_NAME} - Local Development
#
# Services:
#   - Convex Backend:   http://localhost:{3210+OFFSET}
#   - Convex Dashboard: http://localhost:{6791+OFFSET}
# =============================================================================

services:
  backend:
    image: ghcr.io/get-convex/convex-backend:latest
    container_name: {PREFIX}-convex-backend
    ports:
      - "{3210+OFFSET}:3210"
      - "{3211+OFFSET}:3211"
    volumes:
      - {PREFIX}-convex-data:/convex/data
    environment:
      - CONVEX_SITE_URL=http://localhost:3000

  dashboard:
    image: ghcr.io/get-convex/convex-dashboard:latest
    container_name: {PREFIX}-convex-dashboard
    ports:
      - "{6791+OFFSET}:6791"
    environment:
      - CONVEX_BACKEND_URL=http://backend:3210
    depends_on:
      - backend

volumes:
  {PREFIX}-convex-data:
```

---

## Checkliste für neue Projekte

- [ ] Präfix definieren (2-4 Buchstaben)
- [ ] Port-Offset wählen (nicht kollidierend)
- [ ] `docker-compose.dev.yml` anpassen
- [ ] `.env.local` mit korrektem Port
- [ ] Port-Registry aktualisieren

---

## Troubleshooting

### Container-Name existiert bereits

```bash
# Prüfen welche Container laufen
docker ps -a --filter "name=convex"

# Alten Container entfernen (wenn nicht mehr gebraucht)
docker rm -f convex-backend
```

### Port bereits belegt

```bash
# Prüfen was auf Port läuft
lsof -i :3210

# Anderen Offset wählen
```

---

**Last Updated:** 2026-01-30
