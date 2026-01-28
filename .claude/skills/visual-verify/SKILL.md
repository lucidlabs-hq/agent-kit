---
name: visual-verify
description: Visual UI verification with agent-browser. Use after implementing UI components to take screenshots, verify interactions, and self-check your work. FASTER than E2E tests.
allowed-tools: Bash, Read
argument-hint: [url-or-path]
---

# Visual UI Verification

Verwende diesen Skill nach UI-Implementierungen um deine Arbeit visuell zu verifizieren.

## Wann visual-verify vs E2E Tests?

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   DEVELOPMENT (90% der Zeit)        PRODUCTION (10%)            │
│   ─────────────────────────         ──────────────────          │
│   /visual-verify                    E2E Tests (Playwright)      │
│                                                                 │
│   ✅ Schnell (Sekunden)             ✅ Automatisiert            │
│   ✅ Interaktiv                     ✅ CI/CD Integration        │
│   ✅ Flexibel                       ✅ Regression Testing       │
│   ✅ AI Self-Verification           ✅ Kritische Flows          │
│                                                                 │
│   Für: Jede UI-Änderung             Für: Login, Checkout,       │
│        Layout prüfen                     Payment, Signup        │
│        Komponenten testen                                       │
│        Responsive checken                                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Regel:** Agent-Browser für Development-Verification. E2E nur für kritische Production-Flows.

## Voraussetzungen

```bash
# Installation (einmalig)
cd frontend && pnpm add -D agent-browser
pnpm exec agent-browser install  # Chromium downloaden
```

## Workflow

### 1. Dev Server starten (falls nicht läuft)

```bash
cd frontend && pnpm run dev
```

### 2. Seite öffnen und Snapshot machen

```bash
# Seite öffnen
agent-browser open http://localhost:3000/[path]

# Accessibility Snapshot (zeigt interaktive Elemente mit Refs)
agent-browser snapshot -i
```

### 3. Screenshot erstellen

```bash
# Screenshot der aktuellen Ansicht
agent-browser screenshot

# Screenshot mit spezifischem Pfad
agent-browser screenshot ./screenshots/feature-name.png

# Full-Page Screenshot
agent-browser screenshot --full ./screenshots/full-page.png
```

### 4. Interaktionen testen

```bash
# Nach snapshot -i siehst du Refs wie @e1, @e2, etc.

# Element klicken
agent-browser click @e1

# Text eingeben
agent-browser fill @e2 "Test Input"

# Hover
agent-browser hover @e3

# Nach Interaktion: neuer Snapshot + Screenshot
agent-browser snapshot -i
agent-browser screenshot
```

### 5. Viewport testen (Responsive)

```bash
# Mobile Viewport
agent-browser viewport 375 812

# Tablet Viewport
agent-browser viewport 768 1024

# Desktop Viewport
agent-browser viewport 1920 1080

# Screenshot nach Viewport-Änderung
agent-browser screenshot ./screenshots/mobile.png
```

## Self-Verification Workflow

Bei UI-Implementierungen diesen Loop durchführen:

```
┌─────────────────────────────────────────────────────────┐
│                 SELF-VERIFICATION LOOP                  │
│                                                         │
│  1. UI implementieren                                   │
│  2. agent-browser open http://localhost:3000/page       │
│  3. agent-browser snapshot -i (Struktur prüfen)         │
│  4. agent-browser screenshot (visuell prüfen)           │
│  5. Interaktionen testen (click, fill, hover)           │
│  6. Responsive testen (viewport ändern)                 │
│  7. Bei Problemen: Code anpassen, Loop wiederholen      │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Häufige Prüfungen

### Layout prüfen

```bash
# Öffnen und Screenshot
agent-browser open http://localhost:3000/dashboard
agent-browser screenshot ./screenshots/dashboard-layout.png

# Viewport-Varianten
agent-browser viewport 375 812
agent-browser screenshot ./screenshots/dashboard-mobile.png

agent-browser viewport 1920 1080
agent-browser screenshot ./screenshots/dashboard-desktop.png
```

### Interaktive Elemente prüfen

```bash
# Snapshot zeigt alle interaktiven Elemente
agent-browser snapshot -i

# Prüfen ob Button klickbar
agent-browser click @e1
agent-browser snapshot -i  # Zustand nach Klick

# Prüfen ob Form funktioniert
agent-browser fill @e2 "test@example.com"
agent-browser click @e3  # Submit
agent-browser snapshot -i  # Ergebnis prüfen
```

### Hover States prüfen

```bash
# Hover über Element
agent-browser hover @e1
agent-browser screenshot ./screenshots/button-hover.png
```

### Modal/Dialog prüfen

```bash
# Dialog öffnen
agent-browser click @e1  # Trigger Button
agent-browser wait visible "[role='dialog']"
agent-browser screenshot ./screenshots/modal-open.png

# Dialog schließen
agent-browser press Escape
agent-browser screenshot ./screenshots/modal-closed.png
```

## Sessions für isolierte Tests

```bash
# Session für spezifischen Test
agent-browser --session auth-test open http://localhost:3000/login
agent-browser --session auth-test fill @e1 "user@example.com"
agent-browser --session auth-test fill @e2 "password"
agent-browser --session auth-test click @e3
agent-browser --session auth-test screenshot ./screenshots/after-login.png

# Separate Session für anderen Test
agent-browser --session dashboard-test open http://localhost:3000/dashboard
```

## Semantic Locators (Alternative zu Refs)

```bash
# Nach Role suchen
agent-browser find role button click --name "Submit"

# Nach Text suchen
agent-browser find text "Sign In" click

# Nach Label suchen
agent-browser find label "Email" fill "user@test.com"
```

## Checkliste für UI-Verification

Nach jeder UI-Implementation:

- [ ] Desktop Layout korrekt? (screenshot)
- [ ] Mobile Layout korrekt? (viewport + screenshot)
- [ ] Interaktive Elemente klickbar? (snapshot -i + click)
- [ ] Hover States funktionieren? (hover + screenshot)
- [ ] Forms funktionieren? (fill + submit)
- [ ] Modals/Dialogs öffnen/schließen? (click + wait + screenshot)
- [ ] Keine visuellen Fehler? (full-page screenshot)

## Tipps

1. **Immer snapshot -i nach Interaktionen** - Zeigt aktuellen Zustand
2. **Screenshots mit beschreibenden Namen** - `./screenshots/feature-state.png`
3. **Viewport vor Screenshot setzen** - Konsistente Ergebnisse
4. **Sessions für komplexe Flows** - Isolierte Tests
5. **Bei Fehlern: Code anpassen und Loop wiederholen** - Self-Verification

## Referenzen

- [agent-browser GitHub](https://github.com/vercel-labs/agent-browser)
- [Vercel Agent-Browser Docs](https://github.com/vercel-labs/agent-browser/blob/main/README.md)
