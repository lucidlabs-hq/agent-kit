# SSH Keys - Anleitung für Entwickler

> **Purpose:** Anleitung zum Erstellen und Verwenden von SSH Keys für Server-Zugriff.

---

## Was sind SSH Keys?

SSH Keys sind ein sicherer Weg, sich bei Servern anzumelden - ohne Passwort.

```
┌─────────────┐                      ┌─────────────┐
│   Dein PC   │  ── SSH Key ──▶     │   Server    │
│             │                      │             │
│ Private Key │                      │ Public Key  │
│ (geheim!)   │                      │ (bekannt)   │
└─────────────┘                      └─────────────┘
```

- **Private Key:** Bleibt auf deinem PC, NIEMALS teilen!
- **Public Key:** Wird auf Server/Dienste hochgeladen

---

## Schritt 1: Hast du schon einen SSH Key?

### macOS / Linux

```bash
ls -la ~/.ssh/
```

Wenn du `id_ed25519` oder `id_rsa` siehst → Du hast bereits einen Key.

### Windows (PowerShell)

```powershell
dir $env:USERPROFILE\.ssh\
```

---

## Schritt 2: SSH Key erstellen (falls nicht vorhanden)

### macOS / Linux

```bash
# Ed25519 (empfohlen, moderner)
ssh-keygen -t ed25519 -C "dein.name@lucidlabs.de"

# Bei Nachfrage:
# - Speicherort: Enter drücken (Standard)
# - Passphrase: Optional, aber empfohlen für extra Sicherheit
```

### Windows (PowerShell als Admin)

```powershell
# SSH-Agent aktivieren (einmalig)
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent

# Key erstellen
ssh-keygen -t ed25519 -C "dein.name@lucidlabs.de"
```

### Windows (Git Bash)

```bash
ssh-keygen -t ed25519 -C "dein.name@lucidlabs.de"
```

---

## Schritt 3: Public Key anzeigen

Das ist der Key, den du auf Server/Dienste hochlädst.

### macOS / Linux

```bash
cat ~/.ssh/id_ed25519.pub
```

### Windows (PowerShell)

```powershell
cat $env:USERPROFILE\.ssh\id_ed25519.pub
```

### Windows (Git Bash)

```bash
cat ~/.ssh/id_ed25519.pub
```

**Ausgabe sieht so aus:**
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... dein.name@lucidlabs.de
```

**Diese ganze Zeile kopieren!**

---

## Schritt 4: Public Key zu Elestio hinzufügen

1. Elestio Dashboard öffnen
2. Service → **lucidlabs-hq** → Settings
3. **Manage SSH Keys** → **Add Key**
4. **Title:** `dein-name` (z.B. `adam-kassama`)
5. **Key:** Public Key einfügen (die ganze Zeile!)
6. **Save Key**

---

## Schritt 5: Mit Server verbinden

```bash
ssh root@91.98.70.29
# oder
ssh root@projects.lucidlabs.de
```

Beim ersten Mal: `yes` eingeben wenn nach "fingerprint" gefragt wird.

---

## SSH Config (Optional, aber praktisch)

Erstelle/bearbeite `~/.ssh/config`:

```
# Lucid Labs HQ Server
Host lucidlabs-hq
    HostName 91.98.70.29
    User root
    IdentityFile ~/.ssh/id_ed25519
```

Danach einfach:
```bash
ssh lucidlabs-hq
```

---

## Troubleshooting

### "Permission denied (publickey)"

1. **Key auf Server vorhanden?**
   - Prüfe ob dein Key in Elestio unter SSH Keys steht

2. **Richtiger Key wird verwendet?**
   ```bash
   ssh -v root@91.98.70.29
   ```
   Zeigt welcher Key versucht wird.

3. **SSH Agent läuft?**
   ```bash
   # Key zum Agent hinzufügen
   ssh-add ~/.ssh/id_ed25519
   ```

### "Warning: Unprotected private key file"

```bash
# Berechtigungen korrigieren
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

### Windows: SSH Agent Problem

```powershell
# Als Admin ausführen
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent
ssh-add $env:USERPROFILE\.ssh\id_ed25519
```

---

## Für Admins: Neuen User hinzufügen

1. User erstellt seinen Key (Schritt 1-3 oben)
2. User schickt dir seinen **Public Key** (NIEMALS Private Key!)
3. Du fügst den Key in Elestio hinzu:
   - Service → lucidlabs-hq → Settings → SSH Keys → Add Key
   - Title: `vorname-nachname`
   - Key: Public Key einfügen
   - Save

**Alternative:** Direkt auf Server hinzufügen
```bash
ssh root@lucidlabs-hq
echo "ssh-ed25519 AAAAC3... user@email.de" >> ~/.ssh/authorized_keys
```

---

## Best Practices

| Do | Don't |
|----|-------|
| ✅ Ed25519 Keys verwenden | ❌ RSA mit < 4096 bit |
| ✅ Passphrase setzen | ❌ Private Key teilen |
| ✅ Einen Key pro Person | ❌ Shared Keys |
| ✅ Keys in 1Password speichern | ❌ Keys per Email senden |

---

## Quick Reference

```bash
# Key erstellen
ssh-keygen -t ed25519 -C "email@lucidlabs.de"

# Public Key anzeigen (zum Kopieren)
cat ~/.ssh/id_ed25519.pub

# Verbinden
ssh root@91.98.70.29

# Mit Config
ssh lucidlabs-hq
```

---

**Version:** 1.0
**Last Updated:** January 2026
