# CapricaGame - Master Design Guide

*Das komplette Konzept auf einen Blick*

---

## 🎸 WER IST CAPRICA?

**Caprica** ist eine **Rockstar**, die auf ihrem Weg nach Hause von **SLOB Zombies** angegriffen wird – von Musik infizierte Kreaturen, die als Waffe gegen musikalische Künstler eingesetzt werden.

Sie ist nicht nur eine Kriegerin, sondern eine **Musikerin, die kämpft, während sie ihre eigene Musik hört**. Ihre demonialen Flügel sind keine Mutation – sie sind **musikalische Energie-Manifestationen**, die entstehen, wenn sie ihre Kraft kanalisiert.

Im Universum des Spiels gibt es auch **Celestine**, einen musikalischen Engel, der hinter den Kulissen wirkt und Portale erschafft, Level verbindet und letztendlich Capricas kreative Transformation ermöglicht.

---

## 🎵 UM WAS GEHT ES IN DIESEM GAME?

**CapricaGame ist ein Musik-zentrierter Action-Platformer**, in dem Musik nicht einfach nur der Soundtrack ist – **Musik IST das Spielmechanik-System**.

### Core Concept

> "Caprica kämpft zu ihrer Musik. Die Beats sind nicht nur Audio – sie sind Gameplay."

Das Spiel funktioniert nach folgendem Principle:

1. **Welle 1:** Drums + Bass (Grundrhythmus etablieren)
2. **Welle 2:** +Gitarre (Aggression einleiten)
3. **Welle 3:** +Vocals (Climax erreichen)
4. **Boss-Battle:** Vollständiger Song (Crescendo in finalen Kampf)

Jede Welle ist ein Feind-Spawning-Event. Die Musik wird komplexer → der Kampf wird intensiver → das Gefühl baut sich zu einem épischen Moment auf.

### Was macht es besonders?

- **Musik als Unsichtbare Mechanik:** Der Spieler *fühlt* die Beats, ohne darüber nachzudenken
- **Snap-to-Beat Synchronisierung:** 50ms unsichtbare Verzögerung synchronisiert Angriffe mit Musik-Beats
- **Empowerment durch Kreativität:** Nach jedem Boss-Kampf: Home Recording Studio (Music Maker-ähnlich, Spieler arrangiert besiegte Song-Samples)
- **Kohärente Worldbuilding:** Musik als magisches System – nicht nur Storytelling, sondern Universum-Fundament

→ **Siehe:** [CORE_GAME_MECHANIC.md](CORE_GAME_MECHANIC.md), [WORLDBUILDING_MUSIC_MAGIC.md](WORLDBUILDING_MUSIC_MAGIC.md)

---

## 🎮 WIE WIRD DAS GAME GESPIELT?

### Input (NES-Controller kompatibel)

```
D-Pad (Links/Rechts)    = Bewegung
A-Button                = Sprung (Hold für Höhe)
B-Button                = Angriff (ATTACK Intent)
```

### Gameplay Loop

#### 1. **Exploration Phase**
- Bewege Caprica durch Level
- Sammle Coins & Kassetten (Story-Fragmente)
- Finde Türen / Portale zur nächsten Area

#### 2. **Combat Arena Phase**
- Musik startet (Welle 1: Drums+Bass)
- Enemies spawnen progressiv
- **Intent-basierter Combat:**
  - B-Button drücken = `ATTACK` Intent emittiert
  - Spiel auto-dasht zu nächstem Feind
  - Hit-Registration synchronisiert mit Beat (Snap-to-Beat)
  - **Beat-Timing Bonus:** +50% Schaden wenn auf Beat getroffen

#### 3. **Combo-System**
- Kick → Jump → Stomp-Combo-Chain möglich
- **Soft-Docking:** Spieler "dockt" an Feind an (Nähe-Mechanik, nicht hart)
- Knockback erzeugt Knockback-Leverage (GGC-Stil): nutze Impuls um weitre Enemies zu treffen
- Welle endet wenn alle Enemies besiegt

#### 4. **Boss-Battle Phase**
- Finale Welle mit Boss
- Song erreicht Crescendo (alle Instrumente)
- Beat-Timing wird kritischer
- Victory ermöglicht: Eintritt in Home Studio

#### 5. **Home Recording Studio Phase** (Post-Boss)
- Spieler arrangiert **Song-Samples** der besiegten Bosses
- Grid-basiertes Interface (ähnlich Music Maker / Garageband)
- Zielsetzung: **"Mama, I made music!"** – Empowerment durch Kreativität
- Samples werden zu Soundtrack-Elements für kommende Level

### Movement System

**5-Phase Polish Roadmap** (vor Combat):
1. Basis-Gravity & Platform-Jump
2. Double-Jump hinzufügen
3. Wall-Grab & Wall-Slide
4. Dash-Mechanik (kurze Luft-Bewegung)
5. Combo-Movement & Combat-Flow Integration

→ **Siehe:** [MOVEMENT_PRIORITIES.md](MOVEMENT_PRIORITIES.md)

### Combat Details

- **Attack Types:**
  - Kick (schnell, niedrig Damage)
  - Punch (mittel, mittel Damage)
  - Stomp (jump-basiert, hoch Damage)
  - Guitar Power-ups (Axe-swing, Chord-Strum, Flamethrower-Guitar, Machine-Gun-Guitar)

- **Beat-Synchronized Timing:**
  - Snap-to-Beat System micro-verzögert Hits um ~50ms unsichtbar
  - Macht Audio-Visual-Sync perfekt
  - Spieler nimmt es nicht wahr, *fühlt* aber perfekte Timing

→ **Siehe:** [COMBAT_SYSTEM.md](COMBAT_SYSTEM.md), [SNAP_TO_BEAT_SYSTEM.md](SNAP_TO_BEAT_SYSTEM.md), [COMBO_SYSTEM_DETAILED.md](COMBO_SYSTEM_DETAILED.md)

---

## 💬 WAS IST DIE MESSAGE DES GAMES?

### Kernbotschaft

> **"Musik ist Kraft. Musik ist Heilung. Musik ist Schöpfung."**

Das Spiel vermittelt mehrschichtige Botschaften:

### 1. **Künstlerische Empowerment**
- Caprica ist nicht einfach eine Kriegerin – sie ist eine **Musikerin**
- Sie kämpft mit ihrer eigenen Kraft (ihre Musik), nicht mit fremder Waffe
- Post-Game: **Spieler wird selbst Creator** (Home Studio) → "Ich habe Musik gemacht"

### 2. **Musik als Resistenz**
- SLOB Zombies sind "Musik-infiziert" → verdrehte Version musikalischer Kraft
- Caprica kämpft nicht gegen Musik, sondern gegen deren **Missbrauch**
- Ihr Song besiegt verdorbene Songs
- **Metapher:** Künstler vs. Zensur / Kreativität vs. Kontrolle

### 3. **Schnittstellenlosigkeit der Musik**
- Musik durchdringt alles: Combat, Story, Level-Design, Worldbuilding, Empowerment
- Nicht Musik *im* Spiel, sondern Musik *als* Spiel
- Spieler erlebt Musik nicht als Zuschauer, sondern als **aktiver Partizipant**

### 4. **Heimkehr & Familie**
- Caprica will **nach Hause** (nicht "die Welt retten")
- Home Studio-Ending: Sie zeigt ihrer Mama "Ich habe Musik gemacht"
- Intimität statt Apokalypse-Szenario
- **Menschliche Motivation:** Familie, Kreativität, Anerkennung

→ **Siehe:** [WORLDBUILDING_MUSIC_MAGIC.md](WORLDBUILDING_MUSIC_MAGIC.md)

---

## 🎨 ANIMATION ARCHITECTURE: Paperdoll-System

**Wichtige Design-Entscheidung:** Weg von klassischem Animated Sprite Sheet, hin zu **Bone2D Paperdoll Animation**.

### Warum?

✅ **Vorteile:**
- **Reusable Rigs:** Ein Animations-Rig für Caprica, Zombies, NPCs → Code-Reuse
- **Asset-Effizient:** Body-Parts sind einzelne PNG-Dateien (80% weniger Memory)
- **Künstler-freundlich:** Keine perfekte Pixel-Art-Animation nötig, nur saubere Grafiken
- **Flexibel:** Equipment/Skins ohne neue Animationen
- **Godot-native:** Skeleton2D + Bone2D sind eingebaut, keine Plugins nötig

### Wie funktioniert es?

1. **Assets:** Caprica wird aus einzelnen PNG-Teilen zusammengesetzt (Head, Torso, Arme, Beine)
2. **Bones:** Godot Skeleton2D mit Bone-Hierarchie (wie Marionette)
3. **Animation:** Curves bestimmen Bone-Rotation über Zeit
4. **Reuse:** Gleicher Rig mit anderen Body-Parts = neuer Character

→ **Siehe:** [PAPERDOLL_ANIMATION.md](PAPERDOLL_ANIMATION.md)

---

## 🎼 INSPIRATIONSQUELLEN

### Game Design Inspirations

| Quelle | Element | Implementierung |
|--------|---------|-----------------|
| **Celeste** | Präzisions-Movement | Dash, Double-Jump, Wall-Grab Foundation |
| **Bayonetta / GGC** | Knockback-Leverage Mechanic | Multi-Enemy Chaos, Knockback-Leveraging |
| **Warhammer 40K: Shootas Blood & Teef** | Beat-Timed Attacks, Wave-Spawning | Progressive Enemy Waves, Crescendo Music |
| **Crypt of the NecroDancer** | Rhythm-Game Timing Philosophy | Beat-Synchronized Hit Registration |
| **Music Maker / GarageBand** | Home Studio Interface | Post-Boss Sample Arrangement Grid |
| **Portal Series** | Portal Mechanics & Storytelling | Portal System mit Puppet-Manager |

### Audio Design Philosophy

**Rhythm vs QTE (Quick-Time-Event):**
- ❌ QTE: Spiel überrascht Spieler → Panik, Reactive
- ✅ Rhythm: Spieler *antizipiert* Beats → Flow-State, Proactive

Der Spieler hört den Beat kommen und bereitet sich vor. Das ist psychologisch befriedigender.

→ **Siehe:** [RHYTHM_VS_QTE_PHILOSOPHY.md](RHYTHM_VS_QTE_PHILOSOPHY.md), [GGC_INSPIRATION.md](GGC_INSPIRATION.md)

---

## 📋 DEVELOPMENT ROADMAP: ARTEMIS MISSIONS

Das Projekt ist in **4 Missions-Phasen + 1 Foundation Phase** unterteilt, jede mit klaren Learning-Zielen:

### **Mercury 0 (Woche 1, Foundation)**
**Paperdoll Animation Fundamentals** – Bevor wir Game-Logic bauen, müssen wir verstehen wie Godot Bone2D Animation funktioniert.

→ **Siehe:** [ARTEMIS_MISSIONS.md](ARTEMIS_MISSIONS.md#mercury-0-paperdoll-animation-foundation), [PAPERDOLL_ANIMATION.md](PAPERDOLL_ANIMATION.md)

### 🔵 **Mercury Mission** (Woche 1-3)
*Fundamentals: Core Systems Basics*

**Mercury 1-6:**
1. **Beat Detection & Audio-Bus Setup**
2. **Intent Emitter Foundation**
3. **First Enemy (Basic SLOB Zombie)**
4. **Attack System & First Combo**
5. **First Boss & Music Wave System**
6. **Level Loading & Portal Navigation**

**Ziel:** Spielbare 1-Level-Demo mit kompletten Combat-Loop (Exploration → Combat-Arena → Boss-Battle)

→ **Siehe:** [ARTEMIS_MISSIONS.md](ARTEMIS_MISSIONS.md)

---

### 🟢 **Gemini Mission** (Woche 4-7)
*Integration: Systeme verbinden & verfeinern*

**Gemini 1-6:**
1. Home Studio UI Prototype
2. Sample Arrangement System
3. Multiple Enemy Types & Behaviors
4. Combo System Polish & Variations
5. Level Design & Environmental Storytelling
6. Audio System Full Integration (Snap-to-Beat Fine-Tuning)

**Ziel:** 3-Level Campaign mit funktionierendem Post-Boss-Studio

---

### 🟡 **Apollo Mission** (Woche 8-10)
*Production: Vollständiges Game mit Polish*

**Apollo 1-5:**
1. Story Integration (Cassette Collection, Dialogue)
2. Visual Polish (Animations, Effects, Screen Transitions)
3. Boss Variety & Escalation
4. Difficulty Balancing
5. Final Polish & Performance Optimization

**Ziel:** Fertig spielbarer Vertical Slice (4-5 Level + 2-3 Boss Encounters)

---

### 🔴 **Artemis Mission** (Parallel mit Apollo, Woche 8-10)
*Expansion: Home Studio als Creative Experience*

**Artemis 1-3:**
1. Advanced Sample Mixing (Multiple Tracks, Effects)
2. Community Features (Share Arrangements?, Leaderboards?)
3. Extended Music Selection & Boss-Sample Library

**Ziel:** Home Studio wird komplettes Creative-Gaming-Erlebnis auf Augenhöhe mit Combat

---

### Technische Architektur

**Kern-Patterns:**
- **Intent-Based Input System:** Input Decoupling (B-Button → ATTACK Intent → Auto-Dash + Hit-Registration)
- **Component-Based Architecture:** HealthComponent, VelocityComponent, PhysicsComponent, DeathComponent, KillZone
- **Beat-Synchronized Systems:** AudioBus Analysis → Beat Detection → Game Events
- **Puppet Manager:** Portal System mit visueller Kontinuität (Split-Screen Clipping)

→ **Siehe:** [ARCHITECTURE.md](ARCHITECTURE.md), [COMPONENTS.md](COMPONENTS.md)

---

## 📚 DOKUMENTATIONS-STRUKTUR

Diese Master Guide referenziert die detaillierten Sub-Dokumente:

| Dokument | Fokus |
|----------|-------|
| [CORE_GAME_MECHANIC.md](CORE_GAME_MECHANIC.md) | Musik als Kern-Mechanik, System-Übersicht |
| [COMBAT_SYSTEM.md](COMBAT_SYSTEM.md) | Attack-Types, Damage-Berechnung, Wave-System |
| [SNAP_TO_BEAT_SYSTEM.md](SNAP_TO_BEAT_SYSTEM.md) | Audio-Sync Technologie, 50ms Micro-Delay |
| [COMBO_SYSTEM_DETAILED.md](COMBO_SYSTEM_DETAILED.md) | Combo-Chains, Beat-Timing-Bonus, Docking |
| [INTENT_BASED_COMBAT_DETAILED.md](INTENT_BASED_COMBAT_DETAILED.md) | Input Decoupling, Auto-Dash, Automation |
| [DOCKING_SYSTEM_DETAILED.md](DOCKING_SYSTEM_DETAILED.md) | Soft-Docking Mechanik, Gegner-Engagement |
| [HOME_STUDIO_SYSTEM.md](HOME_STUDIO_SYSTEM.md) | Post-Game Creative Experience, Music Maker UI |
| [MOVEMENT_PRIORITIES.md](MOVEMENT_PRIORITIES.md) | 5-Phase Movement Polish Roadmap |
| [WORLDBUILDING_MUSIC_MAGIC.md](WORLDBUILDING_MUSIC_MAGIC.md) | Lore, Celestine, Universe Foundation |
| [RHYTHM_VS_QTE_PHILOSOPHY.md](RHYTHM_VS_QTE_PHILOSOPHY.md) | Audio-First Design Philosophy |
| [GGC_INSPIRATION.md](GGC_INSPIRATION.md) | Knockback-Leverage, Multi-Enemy Design |
| [ARTEMIS_MISSIONS.md](ARTEMIS_MISSIONS.md) | Complete Development Roadmap |
| [PORTAL_SYSTEM.md](PORTAL_SYSTEM.md) | Level-Teleportation mit Puppeteering |

---

## ✅ QUICK START FÜR NEUE CONTRIBUTORS

1. **Game verstehen?** → Lies diese Master Guide
2. **Musik-Mechanic?** → [CORE_GAME_MECHANIC.md](CORE_GAME_MECHANIC.md)
3. **Combat implementieren?** → [COMBAT_SYSTEM.md](COMBAT_SYSTEM.md) + [ARTEMIS_MISSIONS.md](ARTEMIS_MISSIONS.md)
4. **Bewegung programmieren?** → [MOVEMENT_PRIORITIES.md](MOVEMENT_PRIORITIES.md)
5. **Musik synchronisieren?** → [SNAP_TO_BEAT_SYSTEM.md](SNAP_TO_BEAT_SYSTEM.md)

---

## 🎯 KERNWERTE

| Wert | Bedeutung |
|------|-----------|
| **Music First** | Alles läuft von Audio ab, nicht von Input |
| **Player Agency** | Spieler antizipiert, führt aus, experimentiert |
| **Empowerment** | Combat UND Home Studio → zwei Formen von Kraft |
| **Kohärenz** | Musik durchzieht Lore, Mechanik, UI, Story |
| **Zugänglichkeit** | NES-Controller einfach, aber Mastery-Potential |

---

**Version:** 1.0
**Zuletzt aktualisiert:** 30. Dezember 2025
**Status:** Design Complete, Mercury Mission Ready
