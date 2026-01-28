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

**Offizielle Anleitung:** https://docs.elest.io/books/security/page/how-to-connect-to-an-elestio-service-with-ssh-keys

**Kurzfassung:**
1. Elestio Dashboard öffnen
2. Service → **lucidlabs-hq** → Settings
3. **Manage SSH Keys** → **Add Key**
4. **Title:** `dein-name` (z.B. `adam-kassama`)
5. **Key:** Public Key einfügen (die ganze Zeile!)
6. **Save Key**

---

## Schritt 5: SSH Config einrichten (WICHTIG!)

**LUCIDLABS-HQ läuft auf Port 2222** (nicht Standard-Port 22).

Erstelle/bearbeite `~/.ssh/config`:

### macOS / Linux

```bash
nano ~/.ssh/config
```

### Windows

```
notepad %USERPROFILE%\.ssh\config
```

### Config-Inhalt

```
Host lucidlabs-hq
    HostName 91.98.70.29
    User DEIN-USERNAME
    IdentityFile ~/.ssh/id_ed25519
    Port 2222
```

**Ersetze `DEIN-USERNAME`** mit dem Benutzernamen den du vom Admin bekommen hast.

---

## Schritt 6: Mit Server verbinden

```bash
ssh lucidlabs-hq
```

Beim ersten Mal: `yes` eingeben wenn nach "fingerprint" gefragt wird.

**Ohne Config:**
```bash
ssh -i ~/.ssh/id_ed25519 -p 2222 DEIN-USERNAME@91.98.70.29
```

---

## Troubleshooting

### "Permission denied (publickey)"

1. **Key auf Server vorhanden?**
   - Prüfe ob dein Key in Elestio unter SSH Keys steht
   - Frag den Admin ob dein User angelegt wurde

2. **Richtiger Port?**
   ```bash
   # LUCIDLABS-HQ nutzt Port 2222!
   ssh -p 2222 dein-user@91.98.70.29
   ```

3. **Richtiger Key wird verwendet?**
   ```bash
   ssh -v -p 2222 dein-user@91.98.70.29
   ```
   Zeigt welcher Key versucht wird.

4. **SSH Agent läuft?**
   ```bash
   # Key zum Agent hinzufügen
   ssh-add ~/.ssh/id_ed25519
   ```

### "Connection refused" auf Port 22

LUCIDLABS-HQ nutzt **Port 2222**, nicht 22!

```bash
ssh -p 2222 dein-user@91.98.70.29
```

Oder SSH Config mit `Port 2222` anlegen (siehe oben).

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

### 1. User erstellt Key

User folgt Schritt 1-3 oben und schickt dir seinen **Public Key** (NIEMALS Private Key!).

### 2. Key in Elestio hinzufügen

- Service → lucidlabs-hq → Settings → SSH Keys → Add Key
- Title: `vorname-nachname`
- Key: Public Key einfügen
- Save

### 3. User auf Server anlegen

```bash
ssh lucidlabs-hq  # Als Admin

# User anlegen
adduser neuer-user --disabled-password --gecos ""
usermod -aG sudo neuer-user

# SSH Key für User einrichten
mkdir -p /home/neuer-user/.ssh
echo "ssh-ed25519 AAAAC3... user@email.de" > /home/neuer-user/.ssh/authorized_keys
chown -R neuer-user:neuer-user /home/neuer-user/.ssh
chmod 700 /home/neuer-user/.ssh
chmod 600 /home/neuer-user/.ssh/authorized_keys
```

### 4. User informieren

Schick dem User:
- Username: `neuer-user`
- Server: `91.98.70.29`
- Port: `2222`
- Link zu dieser Anleitung

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

# Verbinden (mit SSH Config)
ssh lucidlabs-hq

# Verbinden (ohne Config)
ssh -i ~/.ssh/id_ed25519 -p 2222 dein-user@91.98.70.29
```

## Server Info

| Eigenschaft | Wert |
|-------------|------|
| **IP** | 91.98.70.29 |
| **SSH Port** | 2222 (nicht 22!) |
| **Domain** | projects.lucidlabs.de |

---

**Version:** 1.0
**Last Updated:** January 2026
