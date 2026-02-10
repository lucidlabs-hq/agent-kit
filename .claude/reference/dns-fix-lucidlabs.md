# DNS Fix: lucidlabs.de Wildcard

> **DRINGEND:** SSL-Fehler auf allen *.lucidlabs.de Subdomains

---

## Problem

Der Wildcard-DNS `*.lucidlabs.de` zeigt auf **zwei IPs** (Round-Robin):

```
$ dig *.lucidlabs.de +short
35.71.142.77   ← FALSCH (alter Server?)
91.98.70.29    ← RICHTIG (LUCIDLABS-HQ)
```

**Auswirkung:** Browser verbinden sich zufällig mit dem falschen Server → SSL-Fehler

---

## Lösung

### 1. DNS-Provider öffnen

Login bei eurem DNS-Provider (vermutlich einer von diesen):
- Cloudflare
- AWS Route 53
- Namecheap
- Hetzner DNS

### 2. Wildcard A-Record finden

Suche nach:
```
Type: A
Name: * (oder *.lucidlabs.de)
```

### 3. Falschen Eintrag löschen

**Lösche diesen Eintrag:**
```
Type: A
Name: *
Value: 35.71.142.77   ← LÖSCHEN!
```

**Behalte nur:**
```
Type: A
Name: *
Value: 91.98.70.29    ← BEHALTEN
```

### 4. Änderung speichern

Nach dem Speichern: DNS-Propagation dauert 1-5 Minuten.

---

## Verifizieren

Nach dem Fix testen:

```bash
# Sollte NUR 91.98.70.29 zeigen
dig *.lucidlabs.de +short

# Sollte funktionieren
curl -I https://cotinga-test-suite.lucidlabs.de
```

---

## Betroffene Services

Alle Subdomains sind betroffen:
- cotinga-test-suite.lucidlabs.de
- invoice.lucidlabs.de
- portkey.lucidlabs.de
- (alle anderen *.lucidlabs.de)

---

## Kontakt bei Fragen

Dieser Fix wurde am 2026-01-30 dokumentiert.

IP-Zuordnung:
- `91.98.70.29` = LUCIDLABS-HQ Server (Elestio, Hetzner FSN1)
- `35.71.142.77` = Unbekannt/Veraltet (AWS?)

---

**Priorität: HOCH** - Ohne Fix funktioniert kein SSL auf den Subdomains.
