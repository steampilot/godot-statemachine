# CapricaGame - Core Game Mechanic

## Die Vision

**Caprica ist eine Rockstar, die mit Kopfhörern auf kämpft.**

Sie hört **ihren eigenen Soundtrack** - und **jeden Beat nutzt sie als Waffe** gegen die Zombies.

**Das Spiel ist kein "Rhythmus-Spiel mit Combat".**

Das Spiel ist: **"Ein Spiel über eine Kämpferin, die ZU ihrer Musik kämpft."**

---

## 🎵 Core Mechanic: Music IS Gameplay

### Die Spieler-Fantasy

```
Kopfhörer auf. Musik lädt.
Beat 1, Beat 2, Beat 3...
PERFECT!
Caprica schlägt auf den Beat zu.
Gegner fliegen weg.
Musik wird lauter.
Ich bin EINS mit dem Soundtrack.
```

### Was das bedeutet

**Musik ist nicht:**
- ❌ Ambient Soundtrack (kann man ignorieren)
- ❌ Gimmick für Bonus-Damage
- ❌ "Nice to have" Feature

**Musik ist:**
- ✅ Die **Stimme von Caprica's Intent**
- ✅ Das **Heartbeat** des Kampfes
- ✅ Das **Timing-System** (kein HUD-Timer nötig)
- ✅ Die **Telegrapher** von Gegner-Attacken
- ✅ Das **Feedback** für erfolgreiche Hits
- ✅ Die **Dopamin-Lieferant** (Musik-Peak = Victory)

---

## 🎯 Architektur-Säulen

### 1. **Audio-First Design**
```
Nicht: "Gameplay mit Musik-Overlay"
Sondern: "Musik bestimmt Gameplay-Moment"

Beispiel:
  Drum-Roll in Musik
  → Rhythm-Zombie startet Attack (automatisch)
  → Spieler hört Musik und weiß: "JETZT greife ich an!"
```

### 2. **Snap-to-Beat System**
```
Spieler drückt B (Attack) bei 510ms
Beat kommt bei 545ms
System wartet 35ms (unmerklich!)
Hit landet GENAU auf Beat
= PERFECT Synchronisation
```

### 3. **Intent-Based Combat**
```
Spieler drückt B (ATTACK)
  ↓
Game interpretiert: "Caprica will zum Gegner gehen"
  ↓
Auto-Dash zu Gegner (500 px/s)
  ↓
Hit registriert
  ↓
Snap-to-Beat synchronisiert Impact
  ↓
Musik-Feedback (Extra Drum-Layer)
```

### 4. **Gegner-Musik-Sync**
```
Rhythm-Zombies sind nicht "programmiert zu zufall"

Sie sind "rhythmus-infiziert"
  ├─ Sie greifen auf den Beat an
  ├─ Sie hören die GLEICHE Musik
  ├─ Sie sind musikalische Gegner, nicht feindliche NPCs
  └─ Spieler vs. Musik-Gegner = Dialog statt Mechanik
```

### 5. **Audio-Immersion**
```
Mit Kopfhörer-Fantasy:
  ├─ Musik ist nicht "Soundtrack des Spiels"
  ├─ Musik ist "Was Caprica hört"
  ├─ Spieler hört mit ihr
  ├─ Jeder Hit wird persönlich
  └─ Flow-State entsteht natürlich
```

---

## 📋 Lernschritte (GEMINI → APOLLO Missionen)

Wie in der Apollo-Programm werden wir Step-by-Step lernen und implementieren:

### **PHASE 1: MERCURY** - Grundlagen verstehen
*Ziel: Grundkonzepte lernen, Prototyp bauen*

#### Mercury 1: Audio-Timing-Basics
```
LERNE:
  ├─ Wie Godot 4 Audio-Playback Position tracked
  ├─ Beat-Kalkulationen (BPM → Sekunden)
  ├─ Audio-Time vs. Game-Time Synchronisation
  └─ Erste Beat-Detection implementieren

IMPLEMENTIERE:
  ├─ AUDIO globaler Input: `get_playback_position()`
  ├─ BeatCalculator Klasse (BPM → Beat-Interval)
  ├─ Einfacher Beat-Detector (Debug-Visual)
  └─ Test: Musikbeat im Editor sichtbar machen
```

#### Mercury 2: Intent-Funktion verstehen
```
LERNE:
  ├─ Wie Intent-Emission funktioniert
  ├─ Input → Intent → Action Pipeline
  ├─ Wie Player-States miteinander sprechen
  └─ Cancellation-Flow

IMPLEMENTIERE:
  ├─ IntentEmitter Klasse
  ├─ Attack-Intent Definition
  ├─ Basic Intent-Handler
  └─ Test: Intent drücken, sehen ob registriert
```

#### Mercury 3: Snap-to-Beat Konzept
```
LERNE:
  ├─ Wie man Gameplay verzögert (ohne zu laggen)
  ├─ await create_timer() Patterns
  ├─ 50ms Human-Perception Fenster
  └─ Timing-Toleranzen

IMPLEMENTIERE:
  ├─ SnapToBeatsystem (50ms max)
  ├─ Verzögerung berechnen (Beat - CurrentTime)
  ├─ Await-basierte Execution
  └─ Test: Attack verzögern, testen
```

---

### **PHASE 2: GEMINI** - Systeme zusammenbauen
*Ziel: Zusammenhängende Prototypen, Lernen durch Bauen*

#### Gemini 1: Audio + Combat Fusion
```
LERNE:
  ├─ Wie Audio-Callbacks (on_beat) funktionieren
  ├─ Signal-System in Godot
  ├─ Audio-Events an Gameplay koppeln
  └─ Debugging von Audio-Timing

IMPLEMENTIERE:
  ├─ Beat-Signal System
  ├─ AUDIO emmit beat_occurred Signal
  ├─ Combat-System abonniert Beat
  ├─ On-Beat hit registriert +50% Damage
  └─ Test: Schlag genau auf Beat, +50% sehen
```

#### Gemini 2: Intent → Auto-Dash
```
LERNE:
  ├─ Wie Automation im Combat funktioniert
  ├─ Gegner-Position zu erreichen
  ├─ Animation + Movement kombinieren
  └─ State-Transitions smoothly

IMPLEMENTIERE:
  ├─ Auto-Dash bei Attack-Intent (wenn far)
  ├─ Pull-Gegner-Position in Dash-Ziel
  ├─ Gitarre-Animation (Rücken → Hand)
  ├─ Hit-Detection am Dash-Ende
  └─ Test: B drücken, auto-dash zum Gegner
```

#### Gemini 3: Gegner-Music-Sync
```
LERNE:
  ├─ Wie Gegner-Attacks zeitgesteuert werden
  ├─ Beat-basierte Spawning
  ├─ Visual Telegraphing
  └─ Audio-Cues für Spieler-Warnung

IMPLEMENTIERE:
  ├─ Rhythm-Zombie Basic Implementation
  ├─ Attack-Timer auf Beat setzen
  ├─ Visual Tell (Leuchten, Glow)
  ├─ Audio-Drum-Roll vor Attack
  └─ Test: Zombie greift exakt auf Beat an
```

#### Gemini 4: Snap-to-Beat Combat
```
LERNE:
  ├─ Kombination von Snap + Combat
  ├─ Hit-Landing mit Beat-Synchronisation
  ├─ Screen-Shake + Audio-Feedback timing
  └─ Microsecond-Precision

IMPLEMENTIERE:
  ├─ Attack-Intent + Snap-Kalkulation
  ├─ Verzögerung vor Hit-Registration
  ├─ Beat-basierte Screen-Shake
  ├─ Audio-Impact-Layer (Extra Drum)
  └─ Test: Hit landed exakt auf Beat synchron
```

---

### **PHASE 3: APOLLO** - Vollständiges System
*Ziel: Production-Ready Core Mechanic*

#### Apollo 1: Full Combat Flow
```
LERNE:
  ├─ Wie alles zusammenspielt
  ├─ Edge-Cases debuggen
  ├─ Performance-Optimierung
  └─ Audio-Sync in komplexen Szenen

IMPLEMENTIERE:
  ├─ Kompletter Punch-Kick-Finisher Combo
  ├─ Docking-System (Caprica folgt Gegner)
  ├─ Knockback-Physics
  ├─ Multi-Enemy Management
  └─ Test: Komplette Arena mit 3 Gegnern
```

#### Apollo 2: Music-Driven Arena
```
LERNE:
  ├─ Wave-System (3 Waves pro Arena)
  ├─ Music-Intensity Progression
  ├─ Gegner-Spawn-Timing
  └─ Audio-Mix mit mehreren Layern

IMPLEMENTIERE:
  ├─ Wave-Manager
  ├─ Music-Layers hinzufügen (Drum → Guitar → Vocals)
  ├─ Gegner-Spawn auf Beat
  ├─ Wave-Clear Musik-Peak
  └─ Test: Arena komplett mit Musik-Progression
```

#### Apollo 3: Boss Battle
```
LERNE:
  ├─ Komplexe Attack-Patterns
  ├─ Music-Crescendo-Synchronisation
  ├─ Boss-State Management
  └─ Finale Dopamine-Hit Design

IMPLEMENTIERE:
  ├─ Boss-Enemy mit Multi-Pattern
  ├─ Full Orchestra Audio
  ├─ Musik-Peak beim Death
  ├─ Victory-Sequence
  └─ Test: Boss-Kampf komplett spielbar
```

#### Apollo 4: Polish & Tuning
```
LERNE:
  ├─ Feedback-Design (visuell + audio)
  ├─ Feel-Tuning (responsiveness)
  ├─ Musik-Synchronisations-Precision
  └─ UX-Testing mit echten Spielern

IMPLEMENTIERE:
  ├─ Screen-Shake Tuning (2-3px optimal)
  ├─ SFX-Feedback (PERFECT vs GOOD vs MISS)
  ├─ Visual Effects (Sparks, Glows, Trails)
  ├─ Audio-Mix-Balance
  └─ Test: Alles fühlt sich "professional" an
```

---

## 🎯 Die Lernschritte im Kontext

### Mercury (Missions 1-3)
**Was:** Einzelne Systeme verstehen
**Fokus:** Grundlagen, Prototyp
**Output:** "Ich verstehe Beat-Detection und Intent"

### Gemini (Missions 1-4)
**Was:** Systeme zusammenbauen
**Fokus:** Integration, Zusammenspiel
**Output:** "Ich kann Attack mit Beat synchronisieren"

### Apollo (Missions 1-4)
**Was:** Production-Ready Vollständigkeit
**Fokus:** Spielbarkeit, Feel, Polish
**Output:** "Das Core-Game-Mechanic ist fertig"

---

## 📝 Knowledge Requirements (Was du lernen musst)

### Godot 4 Knowhow

```
KRITISCH:
  ├─ AudioStreamPlayer API
  │   └─ get_playback_position()
  │   └─ finished Signal
  │   └─ get_length()
  │
  ├─ Signal/Slot System
  │   └─ .emit(), .connect()
  │   └─ Custom Signals
  │
  ├─ Timer & Timing
  │   └─ create_timer(delay).timeout
  │   └─ Delta-Time Calculations
  │
  ├─ State Machine Patterns
  │   └─ State-Transitions
  │   └─ Animation States
  │
  └─ Physics2D (Knockback)
      └─ apply_force()
      └─ velocity calculations

WICHTIG:
  ├─ Node Groups & Searching
  ├─ Area2D Collision Events
  ├─ AnimationPlayer Synchronisation
  └─ Debugging & Profiling
```

### Game Design Knowhow

```
KONZEPTIONELL:
  ├─ Intent-Based Input
  │   └─ Decoupling Input from Action
  │
  ├─ Audio as Mechanic
  │   └─ Musik-Timing-Systeme
  │   └─ Audio-Cues vs. Visual Cues
  │
  ├─ Rhythmus-Games Design
  │   └─ Hit-Windows, Perfect/Good/Miss
  │   └─ Timing Tolerance
  │
  ├─ Combat Flow (Combos, Cancellations)
  │   └─ Recovery Times
  │   └─ Chaining Mechanics
  │
  └─ Feel-Tuning
      └─ Responsiveness
      └─ Feedback Timing
      └─ Knockback Feel
```

---

## ✅ Definition of Done: Core Game Mechanic

Wenn folgendes erfüllt ist → **Core Mechanic ist implementiert:**

```
□ Beat-Detection funktioniert (±10ms Accuracy)

□ Intent-System (Input → Action Pipeline) funktioniert

□ Auto-Dash bei Attack triggert zuverlässig
  └─ Gegner wird erreicht, Hit registriert

□ Snap-to-Beat System funktiont
  └─ Hit verzögert sich max 50ms
  └─ Unmerklich für Spieler
  └─ Musik + Impact synchron

□ Combo-System funktioniert
  └─ Punch → Kick → Finisher
  └─ Beat-Timing +50% Damage
  └─ Counter + Timer

□ Gegner-Musik-Sync funktioniert
  └─ Rhythm-Zombie greift auf Beat an
  └─ Visual Tell (Leuchten)
  └─ Audio-Tell (Drum-Roll)
  └─ Spieler kann voraussehen

□ Arena-Flow funktioniert
  └─ 3 Waves mit Musik-Progression
  └─ Gegner-Spawn auf Beat
  └─ Wave-Clear = Musik-Peak

□ Feel & Polish
  └─ Responsive (no input-lag)
  └─ Smooth Animations
  └─ Zufriedenstellendes Feedback
  └─ Musik-Integration fühlt sich organisch an
```

---

## 🎸 Die Essenz

**Caprica ist kein Standard-Action-Game.**

**Caprica ist ein Musik-Spiel mit Combat.**

**Die Spieler-Reise ist:**
1. "Ich drücke B zum Attackieren" (einfach)
2. "Oh, B triggert auto-dash!" (cool)
3. "Moment, die Musik-Synco ist tight!" (whoa)
4. "Ich bin EIN mit dem Soundtrack!" (flow-state)
5. "Ich bin eine Musikerin, keine Kämpferin" (epiphany)

---

**Los geht's? Start mit Mercury 1! 🎵⚔️**
