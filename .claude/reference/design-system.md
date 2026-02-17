# Neola AI Design System Reference

Best Practices für UI-Entwicklung mit Tailwind CSS 4 und Next.js 16.

---

## Table of Contents

1. [Grundprinzipien](#1-grundprinzipien)
2. [Farben](#2-farben)
3. [Typografie](#3-typografie)
4. [Spacing & Layout](#4-spacing--layout)
   - [Surface Divider Rule](#surface-divider-rule-verbindlich)
   - [Chevron Positioning Rule](#chevron-positioning-rule-verbindlich)
   - [Layout Contract: Book Layout](#layout-contract-book-layout-verbindlich)
   - [Unified Column Layout (40/60)](#unified-column-layout-verbindlich)
   - [Registerhaltigkeit](#registerhaltigkeit-verbindlich)
   - [Case Header Pattern](#case-header-pattern-verbindlich)
   - [Header Alignment Rule](#header-alignment-rule-verbindlich)
   - [Action Placement Rule](#action-placement-rule-verbindlich)
   - [Timeline Axis Rule](#timeline-axis-rule-verbindlich)
   - [Workflow Step Rule](#workflow-step-rule-verbindlich)
5. [Komponenten-Patterns](#5-komponenten-patterns)
6. [Status & Prioritäten](#6-status--prioritäten)
7. [Klassifizierung & Editierbare Attribute](#7-klassifizierung--editierbare-attribute) ⭐ NEU
   - [Icon-System](#71-icon-system-final)
   - [IntensityBar](#72-intensitybar-komponente)
   - [ClassificationPill](#73-classificationpill-komponente)
   - [SegmentedDecision](#74-segmenteddecision-komponente)
   - [KLASSIFIZIERUNG Layout](#75-klassifizierung-layout-final)
   - [Workflow Config Block](#76-workflow-config-block-rechte-spalte)
   - [Urgency Badge Styles](#77-urgency-badge-styles-update)
   - [AI Agent Guidelines](#77-ai-agent-guidelines-prompt-ready)
   - [AI Attribution Pattern](#78-ai-attribution-pattern-verbindlich)
   - [Aktion-Container Pattern](#79-aktion-container-pattern-verbindlich)
8. [Tailwind CSS 4 Setup](#8-tailwind-css-4-setup)
9. [Next.js 16 Integration](#9-nextjs-15-integration)
10. [Do's and Don'ts](#10-dos-and-donts)

---

## 1. Grundprinzipien

### Design-Philosophie

| Prinzip | Beschreibung |
|---------|--------------|
| **Flat Design** | Keine Shadows, Tiefe durch Hintergrundfarben |
| **Tailwind Only** | Kein Custom CSS, alles über Utility Classes |
| **Monochrom + Akzent** | Slate für UI, Indigo für Interaktion |
| **Whitespace** | Großzügige Abstände, Luft zum Atmen |
| **Konsistenz** | Wiederkehrende Patterns, keine Sonderlösungen |

### Erforderlich

- **cursor-pointer auf allen klickbaren Elementen** - Buttons, Links, Cards, etc.
- Hover-States für alle interaktiven Elemente
- Transition für smooth interactions (`transition-colors`)

```tsx
// ✅ RICHTIG - Klickbares Element mit cursor-pointer
<div
  onClick={handleClick}
  className="cursor-pointer hover:bg-slate-100 transition-colors"
>

// ✅ RICHTIG - Interaktive Card
<button className="cursor-pointer hover:border-indigo-300 transition-colors">

// ❌ FALSCH - Klickbar ohne cursor-pointer
<div onClick={handleClick} className="hover:bg-slate-100">
```

### Verboten

- Custom CSS-Dateien (außer `globals.css` für Tailwind)
- Inline `style={{ }}` Attribute
- Emojis in der UI (nur wenn explizit angefordert)
- Semantische Farben (Rot/Grün/Orange für Status)
- Box-Shadows auf Cards
- CSS-in-JS Libraries
- Klickbare Elemente ohne `cursor-pointer`
- **Neue UI-Elemente ohne Erlaubnis** (siehe unten)

### UI-Element-Erstellung (VERBINDLICH)

**IMMER um Erlaubnis fragen, bevor neue UI-Elemente erstellt werden.**

| Schritt | Aktion |
|---------|--------|
| 1. Prüfen | Existiert ein passendes Element in `components/ui/`? |
| 2. Wiederverwenden | Wenn ja → bestehendes Element nutzen |
| 3. Fragen | Wenn nein → User um Erlaubnis fragen |
| 4. Konzipieren | Bei Genehmigung → Element gemeinsam designen |

**Beispiele:**
- Tab-Navigation benötigt? → Existierende Tabs/Pills in `components/ui/` prüfen
- Dropdown benötigt? → `ClassificationPill` oder bestehende Dropdown-Patterns nutzen
- Neues Pattern? → Fragen: "Ich benötige ein [X]-Element, das noch nicht existiert. Darf ich eines erstellen?"

**Begründung:** UI-Konsistenz erfordert, dass alle Elemente dem Design-System folgen. Neue Elemente müssen bewusst designed und freigegeben werden.

### Konsistenzregeln (VERBINDLICH)

**GRUNDREGEL:** Alle UI-Elemente desselben Typs MÜSSEN identisch aussehen und sich identisch verhalten. Keine Abweichungen ohne explizite Anforderung.

#### Dropdown-Menüs mit Toggle-Items

Alle Dropdown-Menüs mit auswählbaren Optionen folgen diesem Pattern:

```tsx
// Standard Dropdown-Menü Pattern mit Mini-Checkbox
<div className="absolute right-0 top-full z-10 mt-1 min-w-[220px] rounded-lg border border-divider bg-white py-1 shadow-lg">
  {/* Titel */}
  <div className="px-3 py-1.5 text-xs font-medium text-slate-400">
    Titel hinzufügen
  </div>

  {/* Divider nach Titel */}
  <div className="my-1 border-t border-divider" />

  {/* Toggle Items mit Mini-Checkbox */}
  <button className="flex w-full cursor-pointer items-center gap-2 px-3 py-1.5 text-left text-sm text-slate-600 transition-colors hover:bg-slate-50">
    {/* Mini Checkbox */}
    <span className="flex size-3.5 shrink-0 items-center justify-center rounded border border-slate-300 bg-white">
      {isActive && (
        <Check className="size-2.5 text-primary" strokeWidth={3} />
      )}
    </span>
    Item Label
  </button>
</div>
```

**Struktur:**
```
┌──────────────────────────────────┐
│ [Titel]                          │  ← text-xs font-medium text-slate-400
├──────────────────────────────────┤  ← Divider (my-1 border-t border-divider)
│ ☐ Item 1                         │  ← Mini-Checkbox + Label
│ ☑ Item 2 (aktiv)                 │  ← Checkbox mit blauem Checkmark
│ ☐ Item 3                         │
└──────────────────────────────────┘
```

**Regeln:**
- **Titel:** `text-xs font-medium text-slate-400`
- **Divider:** Nach dem Titel, `my-1 border-t border-divider`
- **Mini-Checkbox:** `size-3.5`, weiß mit slate-300 Border
- **Checkmark (aktiv):** `size-2.5 text-primary strokeWidth={3}`
- **Item-Text:** `text-sm text-slate-600`
- **Item-Padding:** `px-3 py-1.5`
- **Mindestbreite:** `min-w-[220px]` (passt "Dienstleister-Kontakt teilen")

**Checkbox-Styling:**
```tsx
// Inaktiv
<span className="flex size-3.5 shrink-0 items-center justify-center rounded border border-slate-300 bg-white" />

// Aktiv
<span className="flex size-3.5 shrink-0 items-center justify-center rounded border border-slate-300 bg-white">
  <Check className="size-2.5 text-primary" strokeWidth={3} />
</span>
```

#### Anwendungsbereiche

| Bereich | Pattern |
|---------|---------|
| VORGEHEN (Optionale Schritte) | Dropdown-Menü mit Mini-Checkbox |
| AKTION (Textbausteine) | Dropdown-Menü mit Mini-Checkbox |
| Alle zukünftigen Toggle-Listen | Dropdown-Menü mit Mini-Checkbox |

---

## 2. Farben

### Primäre Palette (Indigo + Slate)

```
INDIGO (Interaktion & Akzente)
├── indigo-600  → Primary buttons, active states, links
├── indigo-500  → Hover states
├── indigo-100  → Light backgrounds, selected items
└── indigo-50   → Subtle highlights

SLATE (UI & Text)
├── slate-900   → Primary text, headings
├── slate-700   → Secondary text
├── slate-500   → Tertiary text, placeholders
├── slate-300   → Borders, dividers
├── slate-100   → Card backgrounds, alternating rows
└── slate-50    → Page background
└── white       → Card surfaces
```

### Tailwind Klassen

```tsx
// Text
<p className="text-slate-900">Primary text</p>
<p className="text-slate-700">Secondary text</p>
<p className="text-slate-500">Tertiary text</p>

// Backgrounds
<div className="bg-slate-50">Page background</div>
<div className="bg-white">Card surface</div>
<div className="bg-slate-100">Muted background</div>

// Borders
<div className="border border-slate-200">Standard border</div>
<div className="border border-slate-300">Emphasized border</div>

// Interactive
<button className="bg-indigo-600 hover:bg-indigo-500 text-white">
  Primary Action
</button>
<a className="text-indigo-600 hover:text-indigo-500">Link</a>
```

### Monochrom + 1 Akzent (verbindlich)

**Grundprinzip:** 90-95% Graustufen, 1 Akzentfarbe (Indigo).

| Element | Farbe | Begründung |
|---------|-------|------------|
| **Aktiver Zustand** | Indigo (Accent) | Tabs, Auswahl, Timeline-Dots |
| **CTA-Buttons** | Indigo (Accent) | "Freigeben", Primary Actions |
| **Fortschritt** | Indigo (Accent) | Stepper, aktive Steps |
| **Alles andere** | Graustufen | Badges, Status, Labels, Text |

### Keine semantischen Farben

Status wird NICHT durch Rot/Grün/Orange kommuniziert, sondern durch:
- **Text + Weight** (z.B. "DRINGEND" in semibold)
- **Akzent-Dots** (kleiner Punkt in Indigo für Urgency)
- **Icons** (✓ für "geprüft", nicht grüne Farbe)
- **Position/Reihenfolge**

### Status-Indikatoren (Beispiele)

```tsx
// Urgency - Text + Accent Dot, kein Farb-Badge
<span className="flex items-center gap-1.5 text-xs font-semibold text-slate-700">
  <span className="size-1.5 rounded-full bg-primary" />
  DRINGEND
</span>

// Check-Status - Gray + Icon, kein Grün
<span className="flex items-center gap-1 text-xs text-slate-400">
  <Check className="size-3" />
  Kontakt
</span>

// Timeline - Accent für aktiv, Gray für inaktiv
<div className={isSelected ? "bg-primary" : "bg-slate-300"} />
```

### Anti-Patterns (Farbe)

- ❌ Farbige Status-Badges (Rot, Grün, Orange)
- ❌ Pastell-Hintergründe für Kategorien
- ❌ Mehrere Akzentfarben
- ❌ Farbe als einziger Unterscheidungsfaktor

---

## 3. Typografie

### Font Setup (Geist)

Geist ist in Next.js 16 der Standard-Font. Setup in `app/layout.tsx`:

```tsx
import { GeistSans } from 'geist/font/sans';
import { GeistMono } from 'geist/font/mono';

export default function RootLayout({ children }) {
  return (
    <html lang="de" className={`${GeistSans.variable} ${GeistMono.variable}`}>
      <body className="font-sans antialiased">{children}</body>
    </html>
  );
}
```

### Typography Roles (verbindlich)

**Nur diese 4 Rollen sind erlaubt.** Keine Ausnahmen.

| Role | Purpose | Usage | Tailwind Classes |
|------|---------|-------|------------------|
| **Headline** | Orientation & Structure | Case titles, section headers ("Schadenworkflow", "Arbeitsschritte", "E-Mail an Mieter") | `text-lg font-semibold text-slate-900` |
| **Value** | Decisions & Primary Content | Selected values, active steps, dropdown values, segment selections | `text-base font-medium text-slate-900` |
| **Label** | Context & Field Names | Field labels ("Priorität", "Kontakt", "Ausmaß"), secondary headers | `text-sm text-slate-500` |
| **Meta** | Status & Helper Info | Timestamps, IDs, badges, "Ändern" links, helper text | `text-xs text-slate-400` |

### Größenverhältnisse

| Role | Relative Size | Approx. Pixel |
|------|---------------|---------------|
| Headline | 1.25× Base | ~18px |
| Value (Base) | 1.0× | ~16px |
| Label | 0.9× Base | ~14px |
| Meta | 0.85× Base | ~12px |

### Harte Regeln (nicht optional)

1. **Keine weiteren Stufen**
   - Keine Sub-Headlines
   - Keine Zwischen-Größen
   - Keine Spezialfälle pro Sektion

2. **Labels sind immer leiser als Values**
   - Labels niemals gleich groß oder gleich dunkel wie Values
   - Value gewinnt immer den Blick

3. **Status-Badges = Meta**
   - "Kontakt ok", "Dublette ok", "Dringend"-Badge
   - Klein, ruhig, neutral
   - Niemals visuell mit Headline konkurrieren

4. **Hierarchie durch Raum, nicht durch Schrift**
   - Wenn etwas "größer wirken soll": mehr Weißraum, Position, Gruppierung
   - Nicht durch neue Schriftgrößen

### Anti-Patterns (verboten)

- ❌ Sub-headlines zwischen Headline und Label
- ❌ Leicht größere Labels "for emphasis"
- ❌ Per-component font overrides
- ❌ Visuelle Hierarchie nur durch font-weight
- ❌ Eigenes Styling für Checkbox-Labels, Segment-Controls, Inline-Dropdowns

### Beispiele

```tsx
// Headline - Section Headers
<h2 className="text-lg font-semibold text-slate-900">Schadenworkflow</h2>
<h3 className="text-lg font-semibold text-slate-900">Arbeitsschritte</h3>

// Value - Selected/Active Content
<span className="text-base font-medium text-slate-900">Dringend</span>
<span className="text-base font-medium text-slate-900">Sanitär-Notdienst Schmidt</span>

// Label - Field Names
<span className="text-sm text-slate-500">Priorität</span>
<span className="text-sm text-slate-500">Kontakt</span>

// Meta - Status & Helper
<span className="text-xs text-slate-400">Vor 2 Stunden</span>
<span className="text-xs text-slate-400">#12345</span>
<button className="text-xs text-slate-400 hover:text-slate-600">Ändern</button>
```

### Arbeitsschritte (Timeline)

| State | Typography Role |
|-------|-----------------|
| Aktiver Schritt | **Value** (`text-base font-medium text-slate-900`) |
| Inaktive Schritte | **Meta** (`text-sm text-slate-500`) |

Verbindung über Linie, nicht über Typo.

---

## 4. Spacing & Layout

### Spacing-Skala (4px Base)

| Verwendung | Tailwind | Pixel |
|------------|----------|-------|
| Inline spacing | `gap-1`, `space-x-1` | 4px |
| Icon gap | `gap-2` | 8px |
| Component gap | `gap-4` | 16px |
| Card padding | `p-6` | 24px |
| Section gap | `gap-8` | 32px |
| Page padding | `p-8` | 32px |

### Border Radius

| Element | Tailwind | Wert |
|---------|----------|------|
| Cards | `rounded-xl` | 12px |
| Buttons (pill) | `rounded-full` | 9999px |
| Tags/Badges | `rounded-md` | 6px |
| Inputs | `rounded-lg` | 8px |

### Layout Patterns

```tsx
// Page Layout
<main className="min-h-screen bg-slate-50 p-8">
  <div className="mx-auto max-w-7xl space-y-8">
    {/* Content */}
  </div>
</main>

// Card
<div className="rounded-xl border border-slate-200 bg-white p-6">
  {/* Card content */}
</div>

// Card Grid
<div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
  {/* Cards */}
</div>

// Flex Row with Gap
<div className="flex items-center gap-4">
  {/* Items */}
</div>

// Stack
<div className="flex flex-col gap-4">
  {/* Stacked items */}
</div>
```

### Surface Divider Rule (verbindlich)

**Grundprinzip:** Dividers sind keine dekorativen Elemente. Sie definieren Oberflächen. Wenn ein Divider innerhalb einer Oberfläche existiert, muss er sauber an die Oberflächengrenzen anschließen.

| Regel | Beschreibung |
|-------|--------------|
| **Durchgängigkeit** | Dividers verbinden sich mit Surface-Grenzen (edge-to-edge) |
| **Kein freies Schweben** | Dividers hängen nicht "in der Luft" ohne Verbindung |
| **Vertikale Dividers** | Müssen an horizontale Dividers anschließen (top + bottom) |
| **Negative Margins** | Nutze `-mx-8` um Dividers über padding hinaus zu erweitern |

#### Beispiele

```tsx
// ✅ RICHTIG - Divider verbindet Surface-Kanten
<section className="rounded-xl bg-surface-1 px-8 py-6">
  <div>Content above</div>

  {/* Divider spannt volle Breite */}
  <div className="-mx-8 my-4 border-t border-divider" />

  <div>Content below</div>
</section>

// ✅ RICHTIG - Book Layout mit verbundenen Dividers
<div className="-mx-8 border-t border-divider">
  <div className="flex">
    <div className="w-2/5 px-8 py-6">Left Pane</div>
    <div className="w-px bg-divider" />  {/* Verbindet top und bottom */}
    <div className="flex-1 px-8 py-6">Right Pane</div>
  </div>
  {/* Folgeprozesse - volle Breite unter Book Layout */}
  <div className="border-t border-divider px-8 py-4">
    Full-width content
  </div>
</div>

// ❌ FALSCH - Divider mit Margins innerhalb Container
<section className="px-8">
  <div className="my-4 border-t border-divider" />  {/* Endet vor Kante */}
</section>

// ❌ FALSCH - Vertikaler Divider ohne Verbindung
<div className="flex gap-4 p-8">
  <div>Left</div>
  <div className="h-20 w-px bg-divider" />  {/* Schwebt frei */}
  <div>Right</div>
</div>
```

#### Anwendung in komplexen Layouts

1. **Horizontale Dividers** spannen die volle Container-Breite (`-mx-8 border-t`)
2. **Vertikale Dividers** verbinden zwei horizontale Dividers (top und bottom)
3. **Sections unterhalb** (z.B. Folgeprozesse) erhalten eigene horizontale Trennung
4. **Keine Dividers innerhalb von Flex-Gaps** - verwende strukturelle Trennung

---

### Chevron Positioning Rule (verbindlich)

**Grundprinzip:** Chevrons gehören zum Textblock, nicht zur Karte. Sie sind Teil des Inhalts, kein separates UI-Element am Kartenrand.

| Regel | Beschreibung |
|-------|--------------|
| **Teil des Textblocks** | Chevron direkt nach dem Text mit `gap-1` |
| **Kein justify-between** | Chevron nicht an die rechte Kante pushen |
| **Inline Flow** | Chevron bleibt im Textfluss |

#### Beispiele

```tsx
// ✅ RICHTIG - Chevron als Teil des Textblocks
<span className="flex items-center gap-1">
  <span className="text-sm text-slate-600">Step Title</span>
  <ChevronRight className="size-3.5 text-slate-300" />
</span>

// ✅ RICHTIG - In Timeline Steps
<div className="flex items-start gap-3">
  <div className="timeline-dot" />
  <span className="flex items-center gap-1">
    <span>E-Mail an Mieter</span>
    <ChevronRight className="size-3.5" />
  </span>
</div>

// ❌ FALSCH - Chevron am Kartenrand
<div className="flex items-center justify-between">
  <span>Step Title</span>
  <ChevronRight />  {/* An der rechten Karte */}
</div>

// ❌ FALSCH - Chevron mit flex-1 Spacer
<div className="flex items-center">
  <span className="flex-1">Step Title</span>
  <ChevronRight />  {/* Gepusht durch flex-1 */}
</div>
```

#### Wann Chevrons verwenden

- **Drill-down Navigation** - Zeigt an, dass mehr Details verfügbar sind
- **Editable Content** - Zeigt an, dass Klick eine Bearbeitung öffnet
- **Links zu Detail-Ansichten** - Zeigt Navigation innerhalb der App

---

### Layout Contract: Book Layout (verbindlich)

**Grundprinzip:** Alles, was den Ablauf steuert, bleibt links. Alles, was daraus entsteht, liegt rechts.

| Spalte | Inhalt | Beispiele |
|--------|--------|-----------|
| **Links (Prozess)** | Ablauf, Navigation, Sequenz | Arbeitsschritte, Folgeprozesse |
| **Rechts (Output)** | Ergebnisse, Artefakte, Vorschau | E-Mail Preview, Briefe, Protokolle |

#### Harte Regeln

1. **Folgeprozesse bleiben links** - Kein Verschieben in eigene Zeile
2. **Keine neue Layout-Ebene** - Prozess-Elemente erzeugen keine neue Section
3. **Rechts = nur Output** - Niemals Prozessnavigation rechts
4. **Spalten sind durchgehend** - Linke Spalte endet nicht vor Folgeprozessen

#### Warum das wichtig ist

- **Scan-Logik:** User scannt links für "Was passiert?", rechts für "Was entsteht?"
- **Mentale Prozessführung:** Prozess ist ein kontinuierlicher Fluss, kein Grid
- **Surface-Konsistenz:** Eine logische Einheit = eine visuelle Einheit

#### Struktur

```
┌────────────────────────────────────────────────────────┐
│                   [Header Zone]                        │
├────────────────────────────────────────────────────────┤
│ [Prozess/Execution]      │ [Output/Communication]      │
│                          │                             │
│ • Arbeitsschritte        │ • E-Mail Vorschau           │
│   - Schritt 1            │   [Editierbarer Inhalt]     │
│   - Schritt 2            │                             │
│   - Schritt 3            │                             │
│                          │                             │
│ ─────────────────────    │                             │
│ • Folgeprozesse          │                             │
│   - Prozess A            │                             │
│   - Prozess B            │                             │
│                          │                             │
└────────────────────────────────────────────────────────┘
```

#### Anti-Patterns (verboten)

```tsx
// ❌ FALSCH - Folgeprozesse als eigene Zeile unter dem Layout
<div className="flex">
  <div>Arbeitsschritte</div>
  <div>E-Mail</div>
</div>
<div>Folgeprozesse</div>  {/* Neue Ebene - VERBOTEN */}

// ✅ RICHTIG - Folgeprozesse in der linken Spalte
<div className="flex">
  <div>
    Arbeitsschritte
    <div className="mt-6">Folgeprozesse</div>  {/* Gleiche Spalte */}
  </div>
  <div>E-Mail</div>
</div>
```

---

### Unified Column Layout (verbindlich)

**Grundprinzip:** Alle Sektionen innerhalb einer Surface verwenden dieselbe Spaltenlogik. Kein Sonderlayout pro Zone.

#### Die 40/60 Regel

| Zone | Links (40%) | Rechts (60%) |
|------|-------------|--------------|
| **Config Zone** | Priorität, Beauftragung, Kontakt | Einstellungen (Meta/Flags) |
| **Book Layout** | Arbeitsschritte + Folgeprozesse | E-Mail Preview (Output) |

#### Warum 40/60?

- **Durchgehender Divider** - Eine vertikale Linie von oben bis unten
- **Einheitliche mentale Karte** - Gleiche Struktur oben und unten
- **Responsive-ready** - 40% klappt sauber runter bei Breakpoints

#### Struktur

```
┌────────────────────────────────────────────────────────┐
│ [Header: Workflow wählen · Konfigurieren]              │
├─────────────────────┬──────────────────────────────────┤
│ Priorität    Wert   │ Einstellungen                    │
│ Beauftragung Wert   │   ☐ Selbstbehebung               │
│ Kontakt      Wert   │   ☐ Liegenschaft                 │
│                     │   ☐ Versicherung                 │
│        40%          │            60%                   │
├─────────────────────┼──────────────────────────────────┤
│ Arbeitsschritte     │ E-Mail Vorschau                  │
│   ● Step 1          │ [Preview Content]                │
│   ✓ Step 2          │                                  │
│   ○ Step 3          │                                  │
│ ─────────────────── │                                  │
│ Folgeprozesse       │                                  │
│   · Prozess A       │                                  │
│        40%          │            60%                   │
└─────────────────────┴──────────────────────────────────┘
```

#### Code Pattern

```tsx
// Beide Zonen nutzen identische Proportionen
<div className="flex">
  <div className="w-2/5 shrink-0 px-8 py-4">
    {/* Links: 40% */}
  </div>
  <div className="w-px bg-divider" />
  <div className="flex-1 px-8 py-4">
    {/* Rechts: 60% */}
  </div>
</div>
```

---

### Registerhaltigkeit (verbindlich)

**Grundprinzip:** Wenn zwei Bereiche oder Spalten nebeneinander stehen, MÜSSEN sie immer die gleiche Höhe haben. Der Container wächst nicht - stattdessen wird der Inhalt scrollbar.

#### Regeln

| Regel | Beschreibung |
|-------|--------------|
| **Gleiche Höhe** | Nebeneinanderliegende Spalten haben IMMER dieselbe Höhe |
| **Feste Container** | Container wachsen nicht mit dem Inhalt |
| **Scrollbar bei Überlauf** | Wenn Inhalt zu groß wird → `overflow-y-auto` |
| **Auto-Scroll bei Hinzufügen** | Beim Hinzufügen von Inhalten → zum neuen Element scrollen |

#### Scrollable Content Pattern

```tsx
// ✅ RICHTIG - Feste Höhe, scrollbar bei Überlauf
<div className="flex h-[400px]">
  <div className="w-2/5 overflow-y-auto">
    {/* Linke Spalte - scrollbar */}
  </div>
  <div className="w-px bg-divider" />
  <div className="flex-1 overflow-y-auto">
    {/* Rechte Spalte - scrollbar */}
  </div>
</div>

// ✅ RICHTIG - Flex-basiert mit min-h-0
<div className="flex min-h-0 flex-1 flex-col">
  <div className="flex-1 overflow-y-auto">
    {/* Scrollbarer Inhalt */}
  </div>
</div>

// ❌ FALSCH - Container wächst mit Inhalt
<div className="flex">
  <div className="w-2/5">
    {/* Linke Spalte wächst unbegrenzt */}
  </div>
  <div className="flex-1">
    {/* Rechte Spalte wächst unbegrenzt */}
  </div>
</div>
```

#### Auto-Scroll bei dynamischen Inhalten

Wenn Inhalte dynamisch hinzugefügt werden (z.B. Textbausteine), MUSS:
1. Der Container scrollbar sein
2. Automatisch zum neu hinzugefügten Element gescrollt werden

```tsx
// Pattern für Auto-Scroll
const scrollContainerRef = useRef<HTMLDivElement>(null);
const lastAddedRef = useRef<HTMLDivElement>(null);
const [lastAddedId, setLastAddedId] = useState<string | null>(null);

// Beim Hinzufügen
const addItem = (id: string) => {
  setItems((prev) => [...prev, id]);
  setLastAddedId(id);
};

// Auto-Scroll Effect
useEffect(() => {
  if (lastAddedId && lastAddedRef.current) {
    lastAddedRef.current.scrollIntoView({
      behavior: "smooth",
      block: "nearest",
    });
  }
}, [lastAddedId]);

// JSX
<div ref={scrollContainerRef} className="flex-1 overflow-y-auto">
  {items.map((item) => (
    <div
      key={item.id}
      ref={item.id === lastAddedId ? lastAddedRef : undefined}
    >
      {item.content}
    </div>
  ))}
</div>
```

#### Anwendungsbereiche

| Bereich | Verhalten |
|---------|-----------|
| **Decision View** | Linke + rechte Spalte gleiche Höhe |
| **AKTION Bereich** | Scrollbar, Auto-Scroll bei Textbausteinen |
| **Alle Side-by-Side Layouts** | Registerhaltigkeit obligatorisch |

---

### Case Header Pattern (verbindlich)

**Grundprinzip:** Der Case Identity Header hat eine klare Zwei-Zeilen-Hierarchie. Titel steht allein, Meta ist gruppiert.

#### Zeile 1 – Identity (Titel)

- **Nur der Titel** (H1, Headline)
- Keine Icons, keine Badges, kein Meta
- Darf umbrechen (max 2 Zeilen)

#### Zeile 2 – Meta Row

Eine horizontale Reihe, alle Elemente auf gleicher Baseline:

| Element | Styling | Position |
|---------|---------|----------|
| **Case-ID** | `text-xs text-slate-400` | Links |
| **Priority Badge** | Primary, muted (outline/pastel) | Nach ID |
| **✓ Kontakt** | `text-xs text-slate-400` | Rechts |
| **✓ Dublette** | `text-xs text-slate-400` | Rechts |

#### Badge-Regel (Primary, aber ruhig)

```tsx
// ✅ RICHTIG - Muted Primary (outline style)
<span className="rounded-md border border-primary/30 bg-primary/5 px-2 py-0.5 text-xs font-medium text-primary">
  DRINGEND
</span>

// ❌ FALSCH - Zu laut
<span className="bg-primary text-white">DRINGEND</span>
```

#### Struktur

```
┌────────────────────────────────────────────────────────┐
│ Wasserschaden in Wohnung 3.OG links                    │  ← Zeile 1: Titel
├────────────────────────────────────────────────────────┤
│ #12345  [DRINGEND]              ✓ Kontakt  ✓ Dublette  │  ← Zeile 2: Meta
└────────────────────────────────────────────────────────┘
```

#### Harte Regeln

1. **Titel steht allein** - Nichts konkurriert mit dem Titel
2. **Keine Aktionen** - Header = "Was ist das?", nicht "Was kann ich tun?"
3. **Badge darf Primary sein** - Aber gedämpft, nicht schreiend
4. **Gleiche Baseline** - Alle Meta-Elemente auf einer Linie

---

### Header Alignment Rule (verbindlich)

**Grundprinzip:** Header sind eine horizontale Achse. Titel und Aktionen teilen die gleiche Text-Baseline.

#### Struktur

```
┌────────────────────────────────────────────────────────┐
│ 🔧 Schadenworkflow          Workflow wählen · Konfig.  │
│    ↑                        ↑                          │
│    └── Baseline ────────────┘ (gleiche Linie)          │
└────────────────────────────────────────────────────────┘
```

#### Regeln

1. **`items-baseline`** statt `items-center` auf Header-Flex
2. **Icon optisch korrigiert** - `translate-y-[2px]` damit Text nicht "absackt"
3. **Aktionen = Header-Text** - Keine eigene Padding/Line-Height
4. **Gleiche Line-Height** - Titel und Aktionen harmonisch

#### Code Pattern

```tsx
// ✅ RICHTIG - Shared baseline
<div className="flex items-baseline justify-between">
  <div className="flex items-baseline gap-2">
    <Icon className="size-4 translate-y-[2px]" />  {/* Optisch korrigiert */}
    <h2 className="text-lg font-semibold">Titel</h2>
  </div>
  <div className="flex items-baseline gap-2">
    <button className="text-sm text-slate-400">Aktion 1</button>
    <span>·</span>
    <button className="text-sm text-slate-400">Aktion 2</button>
  </div>
</div>

// ❌ FALSCH - Getrennte Zentrierung
<div className="flex items-center justify-between">
  <div className="flex items-center gap-2">...</div>
  <div className="flex items-center gap-3">...</div>  {/* Baseline driftet */}
</div>
```

---

### Action Placement Rule (verbindlich)

**Grundprinzip:** Es gibt nicht zweimal "Ändern". Aktionen sind gebündelt, nicht verstreut.

#### Inline-Dropdowns

| Element | Funktion | Hat "Ändern"-Link? |
|---------|----------|-------------------|
| Priorität | Statusanpassung | ❌ Nein |
| Beauftragung | Statusanpassung | ❌ Nein |
| Kontakt | Statusanpassung | ❌ Nein |

#### Workflow-Header Aktionen

Oben rechts im Workflow-Header, zwei semantisch getrennte Aktionen:

| Aktion | Zweck |
|--------|-------|
| **"Workflow wählen"** | Strukturelle Entscheidung - ersetzt den Workflow |
| **"Konfigurieren"** | Einstellungen, Regeln, Defaults |

#### Mentales Modell

- **Header** = "Was ist das?"
- **Workflow** = "Was passiert?"
- **Aktionen** = "Wo greife ich grundsätzlich ein?"

---

### Timeline Axis Rule (verbindlich)

**Grundprinzip:** Die vertikale Linie ist das Rückgrat der Timeline. Icons sitzen AUF der Linie, nicht daneben.

#### Struktur

```
     │
     │
   ──●──  ← Icon unterbricht die Linie
     │      Text rechts
     │
   ──✓──  ← Check auf der Linie
     │      Text rechts
     │
   ──⏳──  ← Clock auf der Linie
     │      Text rechts
```

#### Regeln

1. **Durchgehende Linie** - Von erstem bis letztem Schritt
2. **Icons zentriert auf Linie** - Linie läuft durch Icon-Zentrum
3. **Text immer rechts** - Fester Abstand zur Linie
4. **Kein Text unter Steps** - Status nur über Icon codiert

#### Ein-Satz-Regel

> Die vertikale Linie ist durchgehend und bildet die Achse der Arbeitsschritte. Alle Status-Icons sind exakt auf dieser Linie zentriert.

---

### Workflow Step Rule (verbindlich)

**Grundprinzip:** Workflow steps display only the step title. Execution state is communicated via iconography and color, never via descriptive text.

| Zustand | Icon | Bedeutung |
|---------|------|-----------|
| **Aktiv (aktuell)** | ● Filled Dot (Primary) | User ist hier |
| **Kommend** | ○ Empty Dot (Slate) | Noch nicht aktiv |
| **Erledigt (Sabine)** | ✓ Check Icon | Automatisch abgeschlossen |
| **Ausführend** | ⚡ Zap Icon | Wird gerade ausgeführt |
| **Wartend** | 🕐 Clock Icon | Blockiert, externer Trigger |
| **Klickbar** | › Chevron | Detail/Preview möglich |

#### Warum kein Text unter Steps

1. **Redundanz** - Status ist bereits durch Icon codiert
2. **Scanbarkeit** - Liste muss in <1 Sekunde erfassbar sein
3. **Ebenen-Trennung** - "Was passiert" vs "Wer/Wie" müssen getrennt bleiben

#### Wo kommen Details hin?

| Trigger | Ziel | Inhalt |
|---------|------|--------|
| **Hover/Focus** | Tooltip | Kurze Erklärung |
| **Klick** | Rechte Spalte / Drawer | Volle Details, Preview |
| **Aktivitäts-Log** | Separates Panel | Chronologie aller Aktionen |

#### Code Pattern

```tsx
// ✅ RICHTIG - Nur Titel + Icon
<button className="flex items-center gap-3">
  <CheckIcon className="size-4 text-slate-400" />  {/* Status via Icon */}
  <span>Dienstleister beauftragen</span>
</button>

// ❌ FALSCH - Erklärender Text
<button className="flex flex-col gap-1">
  <span>Dienstleister beauftragen</span>
  <span className="text-xs text-slate-400">Erledigt von Sabine</span>  {/* VERBOTEN */}
</button>
```

---

### 3-Column Layout (Desktop)

Für den Links-nach-Rechts Workflow:

```tsx
<div className="grid grid-cols-1 gap-6 lg:grid-cols-12">
  {/* Left: Input Queue */}
  <aside className="lg:col-span-3">
    <TicketQueue />
  </aside>

  {/* Center: Processing */}
  <main className="lg:col-span-6">
    <SabineAgentView />
  </main>

  {/* Right: Output */}
  <aside className="lg:col-span-3">
    <DecisionCards />
  </aside>
</div>
```

---

## 5. Komponenten-Patterns

### Buttons

```tsx
// Primary (Indigo, Pill)
<button className="rounded-full bg-indigo-600 px-6 py-2 text-sm font-medium text-white hover:bg-indigo-500 transition-colors">
  Freigeben
</button>

// Secondary (Outline)
<button className="rounded-full border border-slate-300 bg-white px-6 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50 transition-colors">
  Bearbeiten
</button>

// Ghost
<button className="rounded-full px-4 py-2 text-sm font-medium text-slate-600 hover:bg-slate-100 transition-colors">
  Abbrechen
</button>

// Icon Button
<button className="rounded-full p-2 text-slate-500 hover:bg-slate-100 hover:text-slate-700 transition-colors">
  <MoreHorizontal className="size-5" />
</button>
```

### Cards

```tsx
// Standard Card (Flat, no shadow)
<div className="rounded-xl border border-slate-200 bg-white p-6">
  <div className="flex items-start justify-between">
    <h3 className="text-base font-semibold text-slate-900">Card Title</h3>
    <Badge>Status</Badge>
  </div>
  <p className="mt-2 text-sm text-slate-700">Card content...</p>
</div>

// Interactive Card
<button className="w-full rounded-xl border border-slate-200 bg-white p-6 text-left hover:border-indigo-300 hover:bg-indigo-50/50 transition-colors">
  {/* Card content */}
</button>

// Selected Card
<div className="rounded-xl border-2 border-indigo-600 bg-indigo-50 p-6">
  {/* Selected state */}
</div>
```

### Badges/Tags

```tsx
// Default Badge
<span className="inline-flex items-center rounded-md bg-slate-100 px-2 py-1 text-xs font-medium text-slate-700">
  Standard
</span>

// Emphasized Badge (using Indigo)
<span className="inline-flex items-center rounded-md bg-indigo-100 px-2 py-1 text-xs font-medium text-indigo-700">
  Neu
</span>
```

### Inputs

```tsx
// Text Input
<input
  type="text"
  className="w-full rounded-lg border border-slate-300 bg-white px-4 py-2 text-sm text-slate-900 placeholder:text-slate-400 focus:border-indigo-500 focus:outline-none focus:ring-2 focus:ring-indigo-500/20"
  placeholder="Suchen..."
/>

// Select
<select className="rounded-lg border border-slate-300 bg-white px-4 py-2 text-sm text-slate-700 focus:border-indigo-500 focus:outline-none focus:ring-2 focus:ring-indigo-500/20">
  <option>Option 1</option>
</select>
```

---

## 6. Status & Prioritäten

### Prioritäten (Indigo-Abstufungen)

Status wird durch Indigo-Intensität kommuniziert, nicht durch semantische Farben:

| Priorität | Indigo-Stufe | Tailwind Klassen |
|-----------|--------------|------------------|
| **Kritisch** | Dunkel | `bg-indigo-600 text-white` |
| **Hoch** | Mittel | `bg-indigo-100 text-indigo-700` |
| **Standard** | Hell | `bg-slate-100 text-slate-700` |
| **Niedrig** | Minimal | `bg-slate-50 text-slate-500` |

### Implementierung

```tsx
// Priority Badge Component
const priorityStyles = {
  havarie: 'bg-indigo-600 text-white',      // Dunkelste Stufe = höchste Priorität
  emergency: 'bg-indigo-100 text-indigo-700',
  standard: 'bg-slate-100 text-slate-700',
  low: 'bg-slate-50 text-slate-500',
};

<span className={`inline-flex items-center gap-1.5 rounded-md px-2 py-1 text-xs font-medium ${priorityStyles[priority]}`}>
  <Circle className="size-2 fill-current" />
  {priorityLabel}
</span>
```

### Ticket-Status

| Status | Darstellung |
|--------|-------------|
| Neu | `bg-indigo-100` Badge + "Neu" Text |
| In Bearbeitung | Subtle animation oder Indigo border |
| Wartet auf Freigabe | `border-indigo-300` + Icon |
| Erledigt | `text-slate-500` + Checkmark |

### Icons für Status (Lucide)

```tsx
import { Circle, Clock, CheckCircle2, AlertCircle } from 'lucide-react';

// Neu
<Circle className="size-4 fill-indigo-600 text-indigo-600" />

// In Bearbeitung
<Clock className="size-4 text-indigo-600" />

// Wartet auf Freigabe
<AlertCircle className="size-4 text-indigo-600" />

// Erledigt
<CheckCircle2 className="size-4 text-slate-400" />
```

---

## 7. Editierbare Attribute & Formular-Patterns

### Entscheidungsregeln (verbindlich)

Diese Regeln definieren, wie verschiedene Datentypen dargestellt werden:

| Datentyp | Pattern | Komponente |
|----------|---------|------------|
| **EDITIERBAR** | Pill mit Icon + Wert + Chevron | `ClassificationPill` |
| **INTENSITÄT** | Balken-Skala (ohne Text) | `IntensityBar` |
| **AUSWAHL** | Segmented Control | `SegmentedDecision` |
| **INFORMATION** | Reiner Text | Plain `<p>` |

---

### 7.1 Icon-System für Formulare

> **Kernprinzip:** Ein neutrales Icon pro Kategorie. Keine semantischen Icons.

#### Icon-Kategorien

| Kategorie | Icon | Lucide Name | Verwendung |
|-----------|------|-------------|------------|
| **Klassifizierung** | 🏷️ | `Tag` | Dropdown-Felder für Kategorien/Typen |
| **Scope/Reichweite** | 📚 | `Layers` | Auswahl von Umfang/Betroffenheit |
| **Priorität** | ⚠️ | `AlertCircle` | Dringlichkeits-/Prioritätsstufen |
| **Workflow** | 🔀 | `GitBranch` | Prozess-/Ablaufauswahl |
| **Person** | 👤 | `User` | Kontakt-/Personenauswahl |

#### Icon-Styling (einheitlich)

```tsx
// Standard Icon in Pills
<IconName className="size-4 text-slate-400" strokeWidth={1.5} />

// Icon mit Label
<span className="flex items-center gap-1.5 text-xs text-slate-500">
  <IconName className="size-3.5 text-slate-400" />
  Label Text
</span>
```

#### Anti-Patterns (verboten)

```tsx
// ❌ FALSCH - Semantische Icons für Inhalt
<Toilet />        // Icon zeigt "Bad"
<Wrench />        // Icon zeigt "Reparatur"
<Flame />         // Icon zeigt "Heizung"

// ✅ RICHTIG - Neutrales Icon für Kategorie
<Tag />           // Zeigt "editierbares Feld", nicht den Inhalt
```

---

### 7.2 IntensityBar (Komponente)

Visuelle Intensitäts-Skala ohne Text-Labels für Severity/Dringlichkeit.

```
▮ ▮ ▮ ▮ ▮
```

#### Regeln

- **5 Balken** (feste Anzahl)
- **Nur Indigo-Abstufung** (keine anderen Farben)
- **Keine Text-Labels** (rein visuell)
- **Klickbar zur Auswahl**

#### Props

```typescript
interface IntensityBarProps {
  value: 1 | 2 | 3 | 4 | 5;
  onChange: (value: 1 | 2 | 3 | 4 | 5) => void;
  disabled?: boolean;
  label?: string;  // Optional, über den Balken
}
```

#### Verwendung

```tsx
<IntensityBar
  label="Severity"
  value={3}
  onChange={(v) => setSeverity(v)}
/>
```

#### Farben (selected state)

```typescript
const INTENSITY_COLORS_SELECTED = [
  "bg-indigo-200", // Level 1
  "bg-indigo-300", // Level 2
  "bg-indigo-400", // Level 3
  "bg-indigo-500", // Level 4
  "bg-indigo-600", // Level 5
];
```

---

### 7.3 ClassificationPill (Komponente)

Editierbares Attribut als Pill mit Icon + Wert + Chevron.

```
[ 🏷️ Selected Value ▾ ]
```

#### Regeln

- **Grauer Hintergrund** (neutral, `bg-slate-100`)
- **Icon links** (default: Tag, oder custom per prop)
- **Wert mittig** (flex-1)
- **Chevron rechts** (rotiert bei open)
- **Volle Breite** (default)

#### States

| State | Style |
|-------|-------|
| Default | `bg-slate-100` |
| Hover | `bg-slate-200` |
| Open | `bg-white ring-2 ring-primary` |
| Disabled | `opacity-50 cursor-not-allowed` |

#### Props

```typescript
interface ClassificationPillProps<T extends string> {
  value: T;
  options: readonly T[];
  labels: Record<T, string>;
  onChange: (value: T) => void;
  disabled?: boolean;
  fullWidth?: boolean;  // default: true
  icon?: React.ReactNode;  // default: Tag icon
}
```

#### Verwendung

```tsx
{/* Standard mit Tag-Icon (Kategorien) */}
<ClassificationPill
  value={category}
  options={CATEGORY_OPTIONS}
  labels={CATEGORY_LABELS}
  onChange={setCategory}
/>

{/* Mit Custom Icon (Priorität) */}
<ClassificationPill
  value={priority}
  options={PRIORITY_OPTIONS}
  labels={PRIORITY_LABELS}
  onChange={setPriority}
  icon={<AlertCircle className="size-4 text-slate-400" strokeWidth={1.5} />}
/>

{/* Mit User Icon (Personenauswahl) */}
<ClassificationPill
  value={assignee}
  options={assigneeOptions}
  labels={assigneeLabels}
  onChange={setAssignee}
  icon={<User className="size-4 text-slate-400" strokeWidth={1.5} />}
/>
```

---

### 7.4 SegmentedDecision (Komponente)

Segmented Control für operative Entscheidungen mit begrenzten Optionen.

```
[ Option A | Option B | Option C ]
```

#### Regeln

- **Full-width Container**
- **Gleiche Breite** für alle Segmente
- **Aktives Segment:** Weiß mit leichtem Shadow
- **Inaktive Segmente:** Grau
- **Max 3-4 Optionen** (sonst Dropdown verwenden)

#### Props

```typescript
interface SegmentedDecisionProps<T extends string> {
  options: { value: T; label: string }[];
  value: T;
  onChange: (value: T) => void;
  disabled?: boolean;
  label?: string;
  icon?: React.ReactNode;  // Optional, neben dem Label
}
```

#### Verwendung

```tsx
<SegmentedDecision
  label="Scope"
  icon={<Layers className="size-3.5 text-slate-400" />}
  options={[
    { value: "single", label: "Single" },
    { value: "multiple", label: "Multiple" },
    { value: "all", label: "All" },
  ]}
  value={scope}
  onChange={setScope}
/>
```

---

### 7.5 Formular-Layout Pattern

Die Reihenfolge von Formularfeldern sollte der Entscheidungslogik folgen:

```
1. SEVERITY (IntensityBar)
   → Sofortige visuelle Einschätzung

2. KATEGORIEN (Pills)
   → Details/Spezifikation

3. SCOPE (Segmented)
   → Reichweite/Auswirkung
```

#### Begründung

| Position | Typ | Begründung |
|----------|-----|------------|
| 1 | Intensity | Schnellster visueller Scan |
| 2 | Dropdowns | Detaillierte Auswahl |
| 3 | Segmented | Finale Scope-Entscheidung |

#### Code-Struktur

```tsx
<div className="space-y-4">
  <h3 className="text-xs font-medium uppercase tracking-wide text-slate-500">
    Section Header
  </h3>

  {/* 1. Severity - Intensity bars */}
  <IntensityBar label="Severity" value={severity} onChange={setSeverity} />

  {/* 2. Classification Pills */}
  <div className="space-y-2">
    <ClassificationPill value={type} ... />
    <ClassificationPill value={category} ... />
    <ClassificationPill value={subCategory} ... />
  </div>

  {/* 3. Scope - Segmented */}
  <SegmentedDecision
    label="Scope"
    icon={<Layers className="size-3.5 text-slate-400" />}
    options={SCOPE_OPTIONS}
    value={scope}
    onChange={setScope}
  />
</div>
```

---

### 7.6 Urgency Badge Pattern

Für Dringlichkeits-Badges verwenden wir pastel-Töne, die mit Akzent-Elementen harmonieren:

```typescript
// Pattern für 4-stufige Dringlichkeit
const URGENCY_BADGE_STYLES = {
  critical: "bg-rose-100 text-rose-400 border border-rose-200",
  high: "bg-rose-50 text-rose-400 border border-rose-100",
  medium: "bg-indigo-50 text-indigo-600 border border-indigo-100",
  low: "bg-slate-50 text-slate-500 border border-slate-200",
};
```

**Regel:** Badge-Farbe muss mit Akzent-Elementen (z.B. Sidebar-Balken) übereinstimmen.

---

### 7.7 AI Agent Guidelines (Prompt-Ready)

```
Design form UIs with a clear visual hierarchy:

Component selection:
- Severity/intensity: Use IntensityBar (5-step indigo scale, no labels)
- Categorical selection: Use ClassificationPill (neutral Tag icon)
- Limited options (2-4): Use SegmentedDecision

Icon rules:
- One neutral icon per field category
- Never use semantic icons that represent the content
- All icons: size-4, text-slate-400, strokeWidth 1.5

Layout order:
1. Visual scale first (fastest to scan)
2. Detailed dropdowns second
3. Scope/range selection last

Color rules:
- Dropdowns: slate background (neutral)
- Focus/active: indigo ring
- Urgency: rose pastels for high priority
```

#### Validierungs-Checkliste

| Frage | Erwartung |
|-------|-----------|
| Ist die Severity sofort erkennbar? | Ja (IntensityBar) |
| Sehen alle Dropdowns gleich aus? | Ja (Pills) |
| Sind Icons semantisch überladen? | Nein |
| Ist das Pattern erweiterbar? | Ja |

---

### 7.8 AI Attribution Pattern (verbindlich)

> **Kernprinzip:** AI-Herkunft wird **immer typografisch** markiert, **nie ikonisch**.

#### Regeln

| Regel | Begründung |
|-------|------------|
| **Kein Sparkles-Icon** | Vermeidet "AI-Badge-Überflutung" |
| **Kein AI-Icon** | KI soll unsichtbar helfen, nicht sichtbar prahlen |
| **Typografische Subline** | Stille Herkunftsangabe unter dem Header |
| **Sehr klein (11-12px)** | Deutlich kleiner als Body, nicht ablenkend |
| **Muted-Farbe** | `text-slate-400` – sekundär, nicht dominant |

#### Styling

```tsx
// ✅ RICHTIG - AI Attribution als Typography
<div>
  <h3 className="text-xs font-medium uppercase tracking-wide text-slate-500">
    Section Header
  </h3>
  <span className="text-[11px] text-slate-400">
    Automatically generated
  </span>
</div>

// ❌ FALSCH - AI Attribution als Icon
<h3 className="flex items-center gap-1.5">
  Section Header
  <Sparkles className="size-3 text-slate-400" />  {/* VERBOTEN */}
</h3>
```

#### Anti-Patterns (verboten)

```tsx
// ❌ FALSCH - Sparkles Icon
<Sparkles className="size-3" />

// ❌ FALSCH - AI Badge
<span className="bg-purple-100 text-purple-700">AI Generated</span>

// ❌ FALSCH - Akzentfarbe für AI
<span className="text-primary">Created by AI</span>

// ❌ FALSCH - Zu große Attribution
<span className="text-sm text-slate-600">AI Generated Content</span>
```

#### Wann verwenden

- **AI-generierte Zusammenfassungen** → Subline "Automatically generated"
- **AI-Vorschläge** → Subline unter dem Vorschlags-Header
- **AI-erstellte Inhalte** → Typografischer Hinweis, kein visuelles Element

#### Mentales Modell

> "Der AI-Agent ist ein stiller Helfer im Hintergrund, kein Feature das angepriesen wird."

Die Attribution ist Transparenz für den Nutzer, keine Werbung für AI-Funktionen.

---

### 7.9 Aktion-Container Pattern (verbindlich)

> **Kernprinzip:** Alle Workflow-Step-Details (automatisch, wartend, manuell) werden im gleichen visuellen Container dargestellt.

#### Struktur

```
┌──────────────────────────────────────────────────────┐
│ AKTION                                          [⋮]  │  ← Header (h-6, einheitlich)
├──────────────────────────────────────────────────────┤
│ ┌──────────────────────────────────────────────────┐ │
│ │ [Meta-Line] · [Attribution]                      │ │  ← z.B. "Entwurf · KI-vorbereitet"
│ │                                                  │ │
│ │ [Inhalt]                                         │ │  ← Scrollbar bei Überlauf
│ │                                                  │ │
│ └──────────────────────────────────────────────────┘ │  ← Gradient-Container
└──────────────────────────────────────────────────────┘
```

#### Meta-Line Varianten

| Step-Typ | Meta-Line | Beschreibung |
|----------|-----------|--------------|
| **Manuell (editierbar)** | "Entwurf · KI-vorbereitet" | User kann bearbeiten |
| **Manuell (angepasst)** | "Entwurf · angepasst" | Nach User-Änderung |
| **Automatisch (success)** | "Ausgeführt · von Sabine" | Automatisch abgeschlossen |
| **Automatisch (pending)** | "Wird ausgeführt · von Sabine" | In Bearbeitung |
| **Wartend** | "Wartend · auf externe Aktion" | Blockiert |

#### Code Pattern

```tsx
// Einheitliche Struktur für alle Step-Details
<div className="flex h-full flex-col">
  {/* Header - immer "AKTION", h-6 für Konsistenz */}
  <div className="mb-3 flex h-6 items-center justify-between">
    <h3 className="text-xs font-medium uppercase tracking-wide text-slate-500">
      Aktion
    </h3>
    {/* Optional: Dropdown-Menu (nur bei Mieter informieren) */}
  </div>

  {/* Gradient-Container - visuell immer gleich */}
  <div className="flex min-h-0 flex-1 flex-col rounded-lg bg-gradient-to-b from-indigo-50/40 via-indigo-50/15 to-indigo-50/40">
    <div className="flex-1 overflow-y-auto px-4 py-4">
      {/* Meta-Line - Position immer oben */}
      <p className="mb-4 text-xs text-slate-400">
        {metaText}
      </p>

      {/* Step-spezifischer Inhalt */}
      {children}
    </div>
  </div>
</div>
```

#### Regeln

| Regel | Beschreibung |
|-------|--------------|
| **Header** | Immer "AKTION", kein Icon links vom Titel |
| **Gradient** | Immer `from-indigo-50/40 via-indigo-50/15 to-indigo-50/40` |
| **Meta-Line** | Immer oben im Container, `text-xs text-slate-400` |
| **Scrollbar** | Bei Überlauf, Container-Höhe fix (Registerhaltigkeit) |
| **Konsistenz** | Alle Step-Typen optisch identisch |

#### Anti-Patterns (verboten)

```tsx
// ❌ FALSCH - Icon im Header
<div className="flex items-center gap-2">
  <Zap className="size-4" />
  <h3>AUTOMATISCHER SCHRITT</h3>
</div>

// ❌ FALSCH - Unterschiedliche Header pro Step-Typ
<h3>AUTOMATISCHER SCHRITT</h3>  // Nein
<h3>WARTEND</h3>                // Nein
<h3>AKTION</h3>                 // Ja - immer

// ❌ FALSCH - Unterschiedliche Container-Styles
<div className="bg-slate-50">   // Automatisch - Nein
<div className="bg-indigo-50">  // Manuell - Nein
// Immer: bg-gradient-to-b from-indigo-50/40 via-indigo-50/15 to-indigo-50/40
```

---

## 8. Tailwind CSS 4 Setup

### Overview

**Tailwind CSS v4** uses a **CSS-first approach**. Configuration is done via CSS variables in `@theme inline` blocks, not in a traditional `tailwind.config.js`.

### Installation

```bash
pnpm add tailwindcss @tailwindcss/postcss postcss
```

### postcss.config.mjs

```js
const config = {
  plugins: {
    "@tailwindcss/postcss": {},
  },
};
export default config;
```

### CSS-First Approach with @theme inline

Design tokens are defined directly in CSS:

```css
/* globals.css */
@import "tailwindcss";

/* CSS Variables in :root */
:root {
  --radius: 0.75rem;
  --background: #F1F5F9;
  --foreground: #0F172A;
  --primary: #6366F1;
  --primary-foreground: #FFFFFF;
  --muted: #F1F5F9;
  --muted-foreground: #64748B;
}

/* Map CSS variables to Tailwind tokens */
@theme inline {
  /* Colors */
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --color-primary: var(--primary);
  --color-primary-foreground: var(--primary-foreground);
  --color-muted: var(--muted);
  --color-muted-foreground: var(--muted-foreground);

  /* Typography */
  --font-sans: var(--font-geist-sans), ui-sans-serif, system-ui, sans-serif;
  --font-mono: var(--font-geist-mono), ui-monospace, monospace;

  /* Border Radius */
  --radius-lg: var(--radius);
  --radius-md: calc(var(--radius) - 2px);
  --radius-sm: calc(var(--radius) - 4px);
}

/* Dark Mode (optional) */
@variant dark (&:where(.dark, .dark *));

/* Base Styles */
@layer base {
  * {
    @apply border-slate-200;
  }

  body {
    @apply bg-slate-50 text-slate-900 antialiased;
  }
}

/* Custom Utilities */
@layer utilities {
  .animate-fade-in-up {
    animation: fade-in-up 150ms ease-in;
  }
}

@keyframes fade-in-up {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
```

### Key Points

- **No `tailwind.config.js` needed** (or minimal, if custom plugins required)
- **CSS variables are the source of truth**
- **Tailwind reads from `@theme inline` block** automatically
- **Compatible with shadcn/ui** components

### shadcn/ui Compatibility

**shadcn/ui** is NOT an npm package. It's copy-paste components:
- Components live in `/components/ui/`
- Edit them directly
- They use CSS variables (same as Tailwind v4)
- Compatible with Tailwind v4 CSS-first approach

```tsx
// components/ui/button.tsx uses CSS variables
<button className="bg-primary text-primary-foreground hover:bg-primary/90">
  {/* Works with Tailwind v4 @theme inline */}
</button>
```

### Minimal tailwind.config.ts (If Needed)

Only create if you need custom plugins:

```typescript
// tailwind.config.ts (only if needed)
import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  // Theme is defined in CSS via @theme inline
  plugins: [],
}

export default config
```

### Keine Config-Datei nötig

Tailwind v4 scannt automatisch alle Dateien. Features:
- Auto-detection von Content-Pfaden
- CSS-basierte Konfiguration
- Bessere Performance
- Kleinere Bundle-Größe

---

## 9. Next.js 16 Integration

### Font Setup (Geist lokal)

```bash
pnpm add geist
```

```tsx
// app/layout.tsx
import { GeistSans } from 'geist/font/sans';
import { GeistMono } from 'geist/font/mono';
import './globals.css';

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="de" className={`${GeistSans.variable} ${GeistMono.variable}`}>
      <body className="min-h-screen bg-slate-50 font-sans antialiased">
        {children}
      </body>
    </html>
  );
}
```

### Server Components (Default)

Alle Komponenten sind standardmäßig Server Components. Tailwind funktioniert perfekt damit:

```tsx
// app/controlboard/page.tsx (Server Component)
export default function ControlboardPage() {
  return (
    <main className="p-8">
      <h1 className="text-2xl font-bold text-slate-900">Controlboard</h1>
    </main>
  );
}
```

### Client Components (nur wenn nötig)

```tsx
// components/InteractiveCard.tsx
'use client';

import { useState } from 'react';

export function InteractiveCard() {
  const [isSelected, setIsSelected] = useState(false);

  return (
    <button
      onClick={() => setIsSelected(!isSelected)}
      className={`rounded-xl border p-6 transition-colors ${
        isSelected
          ? 'border-indigo-600 bg-indigo-50'
          : 'border-slate-200 bg-white hover:border-indigo-300'
      }`}
    >
      {/* Content */}
    </button>
  );
}
```

### Responsive Breakpoints

Mobile-first ist Standard in Tailwind:

```tsx
<div className="
  grid
  grid-cols-1        // Mobile: 1 Spalte
  md:grid-cols-2     // Tablet: 2 Spalten
  lg:grid-cols-3     // Desktop: 3 Spalten
  gap-4
">
```

---

## 10. Do's and Don'ts

### Do's

```tsx
// Tailwind Utilities
<div className="flex items-center gap-4 rounded-xl bg-white p-6">

// Conditional Classes mit Template Literals
<div className={`rounded-xl p-6 ${isActive ? 'bg-indigo-50' : 'bg-white'}`}>

// cn() Helper für komplexe Conditions
import { cn } from '@/lib/utils';
<div className={cn(
  "rounded-xl p-6",
  isActive && "bg-indigo-50 border-indigo-300",
  isDisabled && "opacity-50 cursor-not-allowed"
)}>

// Composition über Props
<Card variant="elevated" size="lg">

// shadcn/ui Komponenten nutzen
import { Button } from '@/components/ui/button';
<Button variant="outline" size="sm">Click</Button>
```

### Don'ts

```tsx
// NIEMALS: Custom CSS
// styles/card.css ❌
.card {
  padding: 24px;
  border-radius: 12px;
}

// NIEMALS: Inline Styles
<div style={{ padding: '24px' }}> ❌

// NIEMALS: CSS-in-JS
const StyledCard = styled.div` ❌
  padding: 24px;
`;

// NIEMALS: Emojis für Status
<span>🔴 Havarie</span> ❌

// NIEMALS: Semantische Farben
<span className="bg-red-500">Fehler</span> ❌
<span className="bg-green-500">Erfolg</span> ❌

// NIEMALS: Box Shadows auf Cards
<div className="shadow-lg"> ❌
```

---

## Ressourcen

- [Tailwind CSS v4 Docs](https://tailwindcss.com/docs)
- [Next.js Font Optimization](https://nextjs.org/docs/app/getting-started/fonts)
- [Geist Font](https://vercel.com/font)
- [shadcn/ui](https://ui.shadcn.com/)
- [Lucide Icons](https://lucide.dev/)
