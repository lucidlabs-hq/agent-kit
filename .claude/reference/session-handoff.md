# Session Handoff: Projekt-Wechsel ohne Neustart

## Übersicht

Der Session-Handoff ermöglicht es, von der Agent Kit Basis (Upstream) zu einem Projekt (Downstream) zu wechseln, **ohne** Claude neu starten zu müssen.

## Warum?

- **Problem:** Hand-Off zwischen Sessions funktioniert nicht zuverlässig
- **Lösung:** In der gleichen Session bleiben, Working Directory wechseln
- **Vorteil:** Nahtloser Übergang, Kontext bleibt erhalten

## Workflow

### 1. Start im Agent Kit

```
/prime
```

Claude erkennt: Upstream (Agent Kit Template)

### 2. Projekt-Auswahl

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  VERFÜGBARE PROJEKTE                                                        │
│  ───────────────────                                                        │
│                                                                             │
│  [1] casavi-sandbox-seeder                                                  │
│  [2] client-service-reporting                                               │
│  [3] invoice-accounting-assistant                                           │
│  ...                                                                        │
│                                                                             │
│  [N] Neues Projekt erstellen                                                │
│  [U] Im Upstream (Agent Kit) bleiben                                        │
│                                                                             │
│  An welchem Projekt möchtest du heute arbeiten?                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

User wählt z.B. `3` oder tippt Projektnamen.

### 3. Automatischer Handoff (KEIN /clear nötig!)

Claude wechselt automatisch:

1. Working Directory wechseln: `cd ../projects/[projekt-name]`
2. Handoff-Bestätigung anzeigen:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  ✓ SESSION HANDOFF COMPLETE                                                 │
│                                                                             │
│  ───────────────────────────────────────────────────────────────────────    │
│                                                                             │
│  Neues Working Directory:                                                   │
│  /Users/.../projects/invoice-accounting-assistant                           │
│                                                                             │
│  ⚠️  WICHTIG: Ich arbeite ab jetzt NUR in diesem Projekt.                   │
│      Das Upstream Repository (lucidlabs-agent-kit) wird NICHT verändert.    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

3. Context Header für neues Projekt
4. Boot Screen (Agent Kit Logo, Welcome, etc.)
5. Projekt-Status und nächste Schritte

### 4. Normaler Projekt-Flow

Ab hier läuft alles wie bei einem direkten Start im Projekt:
- Context Header (DOWNSTREAM)
- Boot Screen mit verfügbaren Skills
- Linear Tickets (falls konfiguriert)
- Session Dashboard
- Nächste Schritte

## Regeln nach Handoff

| Erlaubt | Nicht erlaubt |
|---------|---------------|
| Dateien im Projekt lesen/schreiben | Agent Kit Dateien ändern |
| Projekt-spezifische Skills nutzen | Upstream Skills/Docs modifizieren |
| Git im Projekt committen | Git im Agent Kit committen |

## Technische Details

### Projekt-Verzeichnis

Die Projekte liegen auf gleicher Ebene wie das Agent Kit:

```
/Users/.../lucidlabs/
├── lucidlabs-agent-kit/    ← Upstream (hier startest du)
└── projects/
    ├── project-a/          ← Downstream
    ├── project-b/          ← Downstream
    └── ...
```

### Working Directory nach Handoff

```bash
# Vor Handoff
pwd
# → /Users/.../lucidlabs-agent-kit

# Nach Handoff
pwd
# → /Users/.../projects/invoice-accounting-assistant
```

## Handoff bei /init-project

Bei `/init-project` wird der Handoff automatisch nach Projekt-Erstellung durchgeführt:

```
1. User startet /init-project im Agent Kit
2. Template-Auswahl, Projekt-Name, Deployment-Target
3. Projekt wird erstellt in ../projects/[name]/
4. Git init + GitHub repo (optional)
5. AUTOMATISCHER HANDOFF:
   - cd ../projects/[name]
   - Handoff-Bestätigung
   - Boot Screen
   - Projekt bereit für /create-prd
```

**Kein Session-Neustart nötig!** Der User kann direkt weiterarbeiten.

## Unterschied: /prime vs /init-project Handoff

| Aspekt | /prime Handoff | /init-project Handoff |
|--------|----------------|----------------------|
| Trigger | Projekt-Auswahl | Nach Projekt-Erstellung |
| Projekt existiert | Ja | Wird gerade erstellt |
| Nächster Schritt | Weiterarbeiten | /create-prd |
| Kontext | Projekt laden | Frisches Projekt |

## Siehe auch

- `/prime` - Session-Start Skill
- `/init-project` - Neues Projekt erstellen
- `/session-end` - Session sauber beenden
