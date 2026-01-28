# Watchtower - Automatic Container Updates

> **Purpose:** Dokumentiert Watchtower für automatische Docker Container Updates.

---

## Was ist Watchtower?

Watchtower überwacht laufende Docker Container und aktualisiert sie automatisch, wenn neue Images verfügbar sind.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              WATCHTOWER                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. Prüft alle 5 Minuten auf neue Images                                   │
│  2. Pulled neue Version wenn verfügbar                                      │
│  3. Stoppt alten Container graceful                                         │
│  4. Startet neuen Container mit gleichen Parametern                         │
│  5. Räumt alte Images auf                                                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Konfiguration auf LUCIDLABS-HQ

Watchtower läuft im **Label-Enable Mode**:

```yaml
# Nur Container mit diesem Label werden aktualisiert
labels:
  - "com.centurylinklabs.watchtower.enable=true"
```

**Das bedeutet:**
- Watchtower aktualisiert NICHT alle Container
- Nur Container mit explizitem Label werden aktualisiert
- Sicher für Production (keine unerwarteten Updates)

---

## Container für Auto-Update markieren

### In docker-compose.yml

```yaml
services:
  frontend:
    image: myapp/frontend:latest
    labels:
      - "com.centurylinklabs.watchtower.enable=true"  # ← Auto-Update aktiviert
```

### Welche Container markieren?

| Container | Auto-Update? | Grund |
|-----------|--------------|-------|
| **Projekt-Frontend** | ✅ Ja | Schnelle Deployments |
| **Projekt-Mastra** | ✅ Ja | Schnelle Deployments |
| **Caddy** | ❌ Nein | Stabil halten, manuell updaten |
| **n8n** | ❌ Nein | Breaking Changes möglich |
| **Datenbanken** | ❌ NIEMALS | Datenverlust-Risiko |

---

## Umgebungsvariablen

| Variable | Wert | Beschreibung |
|----------|------|--------------|
| `WATCHTOWER_POLL_INTERVAL` | `300` | Prüfintervall in Sekunden (5 min) |
| `WATCHTOWER_CLEANUP` | `true` | Alte Images automatisch löschen |
| `WATCHTOWER_LABEL_ENABLE` | `true` | Nur gelabelte Container updaten |
| `WATCHTOWER_INCLUDE_RESTARTING` | `true` | Auch neustartende Container prüfen |
| `TZ` | `Europe/Berlin` | Zeitzone für Logs |

---

## Notifications (Optional)

### Slack

```yaml
environment:
  - WATCHTOWER_NOTIFICATIONS=slack
  - WATCHTOWER_NOTIFICATION_SLACK_HOOK_URL=https://hooks.slack.com/...
  - WATCHTOWER_NOTIFICATION_SLACK_IDENTIFIER=lucidlabs-hq
```

### Email

```yaml
environment:
  - WATCHTOWER_NOTIFICATIONS=email
  - WATCHTOWER_NOTIFICATION_EMAIL_FROM=watchtower@lucidlabs.de
  - WATCHTOWER_NOTIFICATION_EMAIL_TO=admin@lucidlabs.de
  - WATCHTOWER_NOTIFICATION_EMAIL_SERVER=smtp.example.com
  - WATCHTOWER_NOTIFICATION_EMAIL_SERVER_PORT=587
```

---

## Workflow mit GitHub Actions

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Git Push   │ ──▶ │  Build Image │ ──▶ │  Push to     │ ──▶ │  Watchtower  │
│   to main    │     │  (Actions)   │     │  Registry    │     │  Updates     │
└──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
```

1. Developer pusht zu `main`
2. GitHub Actions baut neues Docker Image
3. Image wird zu Registry gepusht (GHCR, Docker Hub)
4. Watchtower erkennt neues Image (max 5 min)
5. Container wird automatisch aktualisiert

---

## Manuelles Update erzwingen

```bash
# Watchtower einmal manuell triggern
docker exec lucidlabs-watchtower /watchtower --run-once

# Spezifischen Container updaten
docker exec lucidlabs-watchtower /watchtower --run-once invoice-frontend
```

---

## Logs prüfen

```bash
# Watchtower Logs
docker logs lucidlabs-watchtower

# Live Logs
docker logs -f lucidlabs-watchtower

# Letzte Updates
docker logs lucidlabs-watchtower 2>&1 | grep "Updated"
```

---

## Troubleshooting

### Container wird nicht aktualisiert

1. **Label prüfen:**
   ```bash
   docker inspect <container> | grep watchtower
   ```

2. **Image Tag prüfen:**
   - Watchtower braucht `:latest` oder spezifischen Tag
   - Digest-basierte Images werden nicht aktualisiert

3. **Registry erreichbar?**
   ```bash
   docker pull <image>:latest
   ```

### Rollback nach fehlerhaftem Update

```bash
# Vorherige Version starten
docker compose -p project-name down
docker compose -p project-name up -d --force-recreate
```

---

## Best Practices

1. **Immer Label-Mode verwenden** - Nie alle Container automatisch updaten
2. **Staging zuerst** - Neue Versionen erst auf Staging testen
3. **Health Checks** - Container müssen Health Checks haben
4. **Notifications aktivieren** - Wissen wann Updates passieren
5. **Regelmäßig Logs prüfen** - Fehler früh erkennen

---

## Referenzen

- [Watchtower Docs](https://containrrr.dev/watchtower/)
- [GitHub: containrrr/watchtower](https://github.com/containrrr/watchtower)

---

**Version:** 1.0
**Last Updated:** January 2026
