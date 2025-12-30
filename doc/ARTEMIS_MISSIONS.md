# ARTEMIS MISSIONS - Development Roadmap

*Ein strukturiertes Learning & Development Programm für CapricaGame*

---

## Mission Overview

CapricaGame wird in **4 sequenziellen Missions-Phasen** entwickelt, inspiriert von der NASA-Raumfahrt-Nomenklatur:

- 🔵 **Mercury** - Fundamentals: Single Systems Mastery
- 🟢 **Gemini** - Integration: Systeme verbinden & verfeinern
- 🟡 **Apollo** - Production: Vollständiges Spiel mit Polish
- 🔴 **Artemis** - Expansion: Creative Features & Community

Jede Mission hat **klare Learning-Ziele, spielbare Milestones und Definition-of-Done Kriterien**.

---

## 🔵 MERCURY MISSION (Woche 1-3)

**Slogan:** *"One System at a Time"*

**Ziel:** Meistery von einzelnen Core-Systemen. Jede Mercury-Sub-Mission fokussiert auf **ein System in Isolation**.

**Deliverable:** Spielbare 1-Level-Demo mit kompletten Combat-Loop (Exploration → Combat-Arena → Boss-Battle)

### Mercury 0: Paperdoll Animation Foundation
**Learning:** Godot Bone2D, Paperdoll Rigging, Animation-Rig Reusability

- [ ] Caprica Paperdoll-Assets erstellen (einzelne Body-Parts als PNG)
- [ ] Bone2D Rig aufsetzen (Head, Torso, Arms, Legs mit Bones verbinden)
- [ ] Grundlegende Idle-Animation (Breathing, Subtle Movement)
- [ ] Walk-Cycle Animation (Forward, Backward, Stop)
- [ ] Jump-Animation Grundlagen (Startup, Airborne, Landing)
- [ ] NPC Rig für Monster testen (wiederverwendbarer Rig-Aufbau)

**Why First?** Animation ist nicht nur Grafik – es ist **Game Feel**. Das richtige Rig-System macht alle anderen Animationen später 10x einfacher.

**DoD (Definition of Done):**
- Caprica kann idle rumstehen mit subtler Breathing-Animation
- Walk-Cycle sieht natürlich aus
- Bone-Rig ist modular (Head/Arm/Leg unabhängig einsetzbar)
- Eine NPC-Zombie hat das gleiche Rig-System

→ **Dokumentation:** [PAPERDOLL_ANIMATION.md](PAPERDOLL_ANIMATION.md)

---

### Mercury 1: Beat Detection & Audio-Bus Setup
**Learning:** Godot AudioBus, Real-Time Beat Analysis, Signal-Based Events

- [ ] AudioStreamPlayer + AudioBus Analysis einrichten
- [ ] BPM-Detektion aus Audio (oder manuell aus Song-Metadaten)
- [ ] Beat-Pulse-System (emittiert Signal bei jedem Beat)
- [ ] OnBeat() Callback für alle Game-Systeme
- [ ] Debug-Visualization (visueller Beat-Indicator auf Screen)

**Why Here?** Beat-System ist das **Herzstück** des ganzen Spiels. Alles andere synchronisiert sich davon.

**DoD (Definition of Done):**
- Beat-Detektion funktioniert mit Sample-Song
- OnBeat-Signal wird zuverlässig emittiert
- Debug-Modus zeigt Beats auf Screen (visuell verifizierbar)
- Tests bestätigen Timing-Genauigkeit (±50ms)

---

### Mercury 2: Intent Emitter Foundation
**Learning:** Input Decoupling, Intent System Architecture, Action Abstraction

- [ ] IntentEmitter Klasse (nur Input → Intent Konvertierung)
- [ ] Intent Enum: MOVE_LEFT, MOVE_RIGHT, JUMP, ATTACK, INTERACT, CANCEL
- [ ] Input-Polling mit Input.is_action_pressed()
- [ ] Intent Emission System (Signale für jede Intent)
- [ ] Mock-Spieler: Visualisiert Intent-Inputs in Debug-Mode

**Why Here?** Intents sind die **Sprache** zwischen Input und Game-Logic. Clean Input-Handling macht alles modularer.

**DoD (Definition of Done):**
- IntentEmitter sendet MOVE Intent wenn Links/Rechts gedrückt
- JUMP-Intent sendet bei A-Button
- ATTACK-Intent sendet bei B-Button
- Debug-Display zeigt aktuelle Intent in Echtzeit

---

### Mercury 3: First Enemy (Basic SLOB Zombie)
**Learning:** Enemy Spawning, Health System, Death-States, Component-Based Architecture

- [ ] Zombie-Paperdoll mit minimalem Rig
- [ ] HealthComponent (take_damage, health_changed Signal)
- [ ] Collision-Detection (HurtBox für Damage-Take)
- [ ] Idle-State (wandert umher)
- [ ] Hit-Animation (flinch bei Damage)
- [ ] Death-Animation + Removal (mit DeathComponent)

**Why Here?** Enemies sind der Gegner. Ohne sie kein Combat-Spiel.

**DoD (Definition of Done):**
- Zombie spawnt in Level
- Hat 20 Health-Punkte
- Nimmt Damage (von Test-Projectile)
- Stirbt mit Death-Animation
- Signals emittieren bei Health-Change & Death

---

### Mercury 4: Attack System & First Combo
**Learning:** Hitbox/Hurtbox, Damage Calculation, Beat-Timing Bonus, Combo-Chaining

- [ ] Caprica Hit-Box System (Circle2D um Kick-Attacke)
- [ ] Attack-Intent → Kick-Animation + Hitbox-Enable (300ms)
- [ ] Damage Calculation (Base Damage + Beat-Timing Bonus)
- [ ] Beat-Timing Detector: War Hit im Beat-Fenster?
- [ ] +50% Damage Bonus wenn auf Beat
- [ ] Combo-Counter: Kick → Punch möglich (Fenster: 1.5s)

**Why Here?** Combat ist das Kern-Gameplay-Loop. Attaicks ohne Beat-Timing ist 80% des Spiels.

**DoD (Definition of Done):**
- B-Button → Kick-Animation (mit Hitbox)
- Hit registriert Damage auf Zombie
- Beat-Timing Bonus funktioniert (+50% wenn auf Beat)
- Combo-Input funktioniert (Kick gefolgt von Punch im 1.5s Fenster)
- Damage-Zahlen sichtbar auf Screen

---

### Mercury 5: First Boss & Music Wave System
**Learning:** Boss AI, Progressive Music Layering, Wave-Event System

- [ ] Boss-Zombie (5x Health von Regular-Zombie)
- [ ] Boss-Paperdoll mit aggressiveren Animations
- [ ] Music-Wave System:
  - Wave 1: Drums + Bass (Spiel-Start)
  - Wave 2: +Gitarre (20 Sekunden später)
  - Wave 3: +Vocals (weitere 20 Sekunden)
- [ ] Wave-Event Triggering (Audio-Track Layer werden hinzugefügt)
- [ ] Visual Intensity Scaling (Hintergrund, Effekte werden intensiver)

**Why Here?** Der Boss ist der "Crescendo-Moment". Music-Wellen sind das Rückgrat des Rhythm-Systems.

**DoD (Definition of Done):**
- Boss spawnt nach regulären Enemies besiegt
- Song startet mit Drums+Bass nur
- Nach 20s schaltet Gitarre ein
- Nach weiteren 20s schalten Vocals ein
- Boss ist sichtbar aggressiver in Wave 3
- Beat-Timing ist kritischer (mehr Schaden möglich)

---

### Mercury 6: Level Loading & Portal Navigation
**Learning:** Scene Management, Portal System, Spawn-Points, Level Transitions

- [ ] Level-Scene-Struktur (Exploration Area + Combat Arena + Boss Arena)
- [ ] Portal-Objekt (Area2D, Trigger bei Kontakt)
- [ ] Portal-Destination Mapping (zu nächstem Level)
- [ ] Spawn-Point System (Caprica spawnt hier nach Portal)
- [ ] Fade-to-Black Transition
- [ ] Puppet-Manager Basis (für optionale visuelle Continuity später)

**Why Here?** Portale sind die "Naht" zwischen Level. Funktioniert Level-Loading nicht, kein Multi-Level Game.

**DoD (Definition of Done):**
- Level 1 hat Portal am Ende
- Caprica geht durch Portal → Fade → Level 2 startet
- Caprica spawnt am Spawn-Point von Level 2
- Camera folgt Caprica in neuem Level

---

## 🟢 GEMINI MISSION (Woche 4-7)

**Slogan:** *"Systems in Harmony"*

**Ziel:** Integration mehrerer Systeme. Gemini fokussiert auf **Systeme verbinden, Polishing und Variety**.

**Deliverable:** 3-Level Campaign mit funktionierendem Post-Boss Home-Studio

### Gemini 1: Home Studio UI Prototype
**Learning:** Godot UI, Grid-Based Layout, Sample-Arrangement Interface

- [ ] Music Maker-ähnliches Grid UI (8x8 oder 12x12 Sample-Slots)
- [ ] Drag-and-Drop Sample-Placement
- [ ] Play-Button um Arrangement abzuspielen
- [ ] Save/Load Arrangements
- [ ] Basic Visual Feedback (Sample-Color, Waveform-Preview)

### Gemini 2: Sample Arrangement System
**Learning:** Audio Mixing in Godot, Dynamic Track-Layering

- [ ] Boss-Sample-Library (Samples der besiegten Bosses)
- [ ] Multi-Track Audio-Mixing (bis zu 4 simultane Tracks)
- [ ] Sample-Selection UI
- [ ] Arrangement → AudioMix Rendering
- [ ] Leaderboard / Share-Mechanik (optional)

### Gemini 3: Multiple Enemy Types & Behaviors
**Learning:** Enemy Variants, Behavior Trees, Spawn-Patterns

- [ ] Zombie-Type 1: Slow (viel Health, wenig Schaden)
- [ ] Zombie-Type 2: Fast (wenig Health, schnell)
- [ ] Zombie-Type 3: Ranged (spuckt Projectiles)
- [ ] Enemy-Spawn-Patterns (Wave 1: 3x Slow, Wave 2: 5x Fast + 2x Ranged)

### Gemini 4: Combo System Polish & Variations
**Learning:** Animation Cancelling, Input-Buffering, Flow-State Design

- [ ] Combo-Windows optimieren (Input-Buffer: 200ms vor Animation-Ende)
- [ ] Kick → Punch → Stomp Combo (3-Hit-Chain)
- [ ] Alternative Combos (Kick → Jump → Stomp möglich)
- [ ] Combo-Counter visuell anzeigen (UI-Element zählt Hits)
- [ ] Combo-Damage-Scaling (+10% Damage pro Combo-Hit)

### Gemini 5: Level Design & Environmental Storytelling
**Learning:** Level-Layout, Environmental Hints, Collectibles (Cassettes)

- [ ] Level 2 & 3 designen (unterschiedliche Biome/Settings)
- [ ] Cassette-Collectibles platzieren (Story-Fragmente)
- [ ] Environmental Storytelling (Visuelle Hinweise auf Lore)
- [ ] Difficulty-Ramping (Level 3 ist harder als Level 2)

### Gemini 6: Audio System Full Integration & Snap-to-Beat Fine-Tuning
**Learning:** Audio-Visual Sync, Latency-Compensation, Micro-Delay System

- [ ] Snap-to-Beat Micro-Delay (50ms max) fein-tunen
- [ ] Hit-Registration an Beat-Pulse ankoppeln
- [ ] Audio-Latency messen & kompensieren
- [ ] Beat-Visualization für Testing/Debugging
- [ ] A/B Testing: Mit vs Ohne Snap-to-Beat

---

## 🟡 APOLLO MISSION (Woche 8-10)

**Slogan:** *"From Prototype to Product"*

**Ziel:** Vollständiges spielbares Spiel mit Production-Quality Polish.

**Deliverable:** Vertical Slice (4-5 Level + 2-3 Boss Encounters, Story-Complete, Polish-Ready)

### Apollo 1: Story Integration (Cassette Collection, Dialogue)
- [ ] Cassette-UI (zeigt gesammelte Story-Fragmente)
- [ ] Dialogue-System (NPC-Conversations, Lore-Drops)
- [ ] Intro-Cinematic (Caprica's Tag vor dem SLOB-Angriff)
- [ ] Boss-Dialogue (Boss spricht vor Kampf)

### Apollo 2: Visual Polish (Animations, Effects, Screen Transitions)
- [ ] Blood/Juice-Effekte bei Hit-Registration
- [ ] Dust-Particles bei Dash
- [ ] Screen-Shake bei Boss-Angriff
- [ ] Transition-FX zwischen Levels (nicht nur Fade-to-Black)
- [ ] Victory-Animation nach Boss-Defeat

### Apollo 3: Boss Variety & Escalation
- [ ] 3 unterschiedliche Bosses (unterschiedliche Designs, Attack-Patterns)
- [ ] Boss-Spezial-Attacken (AoE, Laser, Grab-Mechanic)
- [ ] Difficulty-Curve (Boss 1 easiest, Boss 3 hardest)
- [ ] Boss-Lore (wer sind diese Zombies? Warum sind sie infiziert?)

### Apollo 4: Difficulty Balancing & Player Feedback
- [ ] Easy/Normal/Hard Mode (unterschiedliche Enemy-Health)
- [ ] Feedback-Tuning (ist +50% Damage-Bonus zu viel? Zu wenig?)
- [ ] Player-Testing & Iteration
- [ ] HUD-Improvements (Clear Health-Bar, Combo-Display, Beat-Indicator)

### Apollo 5: Final Polish & Performance Optimization
- [ ] Frame-Rate Optimization (60fps consistent)
- [ ] Audio-Sync-Tuning (keine Latency-Probleme)
- [ ] Bug-Fixes & Edge-Case-Handling
- [ ] Final Sound-Design & Music-Mastering

---

## 🔴 ARTEMIS MISSION (Parallel mit Apollo, Woche 8-10)

**Slogan:** *"Creative Empowerment"*

**Ziel:** Home Studio als gleichwertiges Creative-Gaming-Feature neben Combat.

**Deliverable:** Komplettes Creative-Gaming-Erlebnis

### Artemis 1: Advanced Sample Mixing
- [ ] Multi-Track Support (bis zu 8 Tracks simultane Playback)
- [ ] Per-Track Volume & Panning
- [ ] Basic Effects (EQ, Reverb, Delay)
- [ ] Loop-Point Editing (Sample-Start/End anpassen)

### Artemis 2: Community Features
- [ ] Share-Arrangements (Cloud-Upload oder lokaler Export)
- [ ] Leaderboard (beste Arrangements basierend auf... Upvotes? Creativity Score?)
- [ ] Gallery-Modus (andere Spieler-Kreationen anhören)
- [ ] Rating-System

### Artemis 3: Extended Music Selection & Boss-Sample Library
- [ ] Alle 5-7 Boss-Samples verfügbar in Studio
- [ ] Zusätzliche Drum/Bass/Ambient-Loops zum Mischen
- [ ] Genre-Variety (verschiedene Musik-Stile für verschiedene Bosses)
- [ ] Remix-Potential (Game-Musik vs Player-Kreation)

---

## Roadmap Timeline

```
WEEK 1-3:  Mercury    (Foundation)  →  Spielbare 1-Level-Demo
WEEK 4-7:  Gemini     (Integration) →  3-Level Campaign
WEEK 8-10: Apollo     (Production)  +  Artemis (Creative) → Full Vertical Slice
```

---

## Success Metrics

### Mercury (Done when...)
- [ ] Beat-Detection zuverlässig funktioniert
- [ ] Intent-System sauber implementiert
- [ ] 1 Level spielbar mit 1 Boss
- [ ] Beat-Timing Bonus ist spürbar
- [ ] Paperdoll-Animation sieht gut aus

### Gemini (Done when...)
- [ ] 3 Level spielbar mit 3 Bosses
- [ ] Home Studio UI funktioniert
- [ ] Multiple Enemy-Types
- [ ] Audio-Sync perfekt
- [ ] Playtesters sagen "das ist ein Game!"

### Apollo (Done when...)
- [ ] Vollständige Geschichte erzählt
- [ ] Alle Visual-Effects polished
- [ ] Difficulty-Balancing getestet
- [ ] Performance-Bottlenecks gelöst
- [ ] Vertical Slice "releasable"

### Artemis (Done when...)
- [ ] Studio-Interface ist intuitiv
- [ ] Sample-Mixing funktioniert
- [ ] Spieler möchten ihre Kreationen teilen
- [ ] Community engagiert sich

---

## Key Design Decisions to Lock-In

| Phase | Decision | Rationale |
|-------|----------|-----------|
| **Mercury** | Paperdoll Animation statt Sprite Sheets | Reusable Rigs, weniger Asset-Work, Flexibility |
| **Mercury** | Intent-Based Input (nicht Direct Input) | AI/Replay/Automation später einfach |
| **Gemini** | Music Maker-Style UI (nicht komplexer DAW) | Accessible, Casual-Friendly |
| **Apollo** | 4-5 Level Story (nicht infinite Roguelike) | Narrative Closure, Clear Ending |
| **Artemis** | Post-Game Studio (nicht In-Game) | Separate Creative-Space, Empowerment-Moment |

---

## Version History

**v1.0** – 30. Dezember 2025
Initial complete roadmap with all missions defined.
