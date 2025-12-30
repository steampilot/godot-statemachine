# Caprica Combat System - Design Document

## Überblick

**CapricaGame** ist ein aggressiver, musikgetriebener 2D Combat-Platformer.
Caprica, die Rockstar-Zombiekämpferin, kämpft sich mit Gitarrenangriffen, schnellen Bewegungen und präzisem Timing durch Horden von SLOB-Zombies.

Das Combat-System kombiniert:
- **Aggressive Momentum-basierte Bewegung** (kein Precision-Platforming)
- **Schnelle Action-Combos** mit Cancellations
- **Arena-basierte Level** statt linearer Progression
- **Musik-synchronisierte Angriffe** für Bonus-Damage
- **Multiple Gegnertypen** mit verschiedenen Verhaltensweisen

---

## 1. Movement System

### Philosophie
Bewegung ist **kein Puzzle** sondern **Combat-Tool**. Jeder Move existiert, um Angriffe zu ermöglichen oder Schaden zu vermeiden.

### Core Movement Moves

#### **Dash (Aggressive Engagement)**
```
Bewegung: Links/Rechts
Geschwindigkeit: 500
Dauer: 0.15s (schnell!)
Cooldown: 0.3s
Besonderheit: Can be cancelled into Attack, Kick, Double Jump
Momentum: Wird in Attack mitgenommen
```

**Zweck:** Schnelle Näherung zu Gegner, Escape, Repositionierung

**Visuelle Idee:**
```
Caprica sprintet mit Gitarre voran
Bewegungslinien hinter ihr
Auditory: Schnelle Drum-Schlag
```

---

#### **Jump (Combat Recovery)**
```
Höhe: 200
Double Jump: JA (Air Defense!)
Wall Jump: NEIN
Air Dash: JA (zusätzliche Escape)
Cancellable into: Attack, Kick
```

**Zweck:**
- Gegner ausweichen (vertikal)
- Auf Plattformen für Positioning springen
- Recovery nach Knockback

**Doppel-Jump als Feature:**
- Erste Jump: Normal
- Zweite Jump: Air-Defense gegen Gegner-Angriffe
- Bricht Gegner-Momentum

---

#### **Wall Grab (Positioning Setup)**
```
Aktivierung: In die Wand springen
Dauer: Solange gehalten
Bewegung: Slide langsam runter
Cancellable into: Jump (raus), Attack (Wandangriff)
```

**Zweck:**
- Setup für nächste Combo (Zeit zum Atmen)
- Gegnerpositionierung beobachten
- Sichere Spot vor Knockback

**Visuelle Idee:**
```
Caprica lehnt an der Wand
Gitarre ist bereit
Musiknoten fliegen um sie
```

---

#### **Ladder (Navigation + Safe Spot)**
```
Aktivierung: In die Leiter springen
Bewegung: Auf/Ab klettern
Geschwindigkeit: Langsam (100)
Sicherheit: Kurze Invulnerabilität
Cancellable into: Jump (absprung)
```

**Zweck:**
- Level-Navigation zwischen Arenen
- Sichere Spot um Gegner zu warten
- Zugang zu höheren Plattformen

---

### Movement State Machine

```
IDLE
  ↓ [Move Input]
MOVE (Strafing left/right, 200 speed)
  ↓ [Dash Button]
DASH (500 speed, 0.15s)
  ├─→ [Attack Button] → ATTACK
  ├─→ [Kick Button] → KICK
  ├─→ [Jump] → JUMP
  └─→ [Expire] → MOVE

MOVE
  ├─→ [Attack] → ATTACK (0.25s recovery, cancellable)
  ├─→ [Kick] → KICK (0.35s recovery, cancellable)
  ├─→ [Jump] → JUMP (vertikal)
  └─→ [Stop] → IDLE

JUMP
  ├─→ [Double Jump] → JUMP (air)
  ├─→ [Wall] → WALL_GRAB
  ├─→ [Attack] → ATTACK (mid-air)
  └─→ [Land] → MOVE

ATTACK (0.25s recovery)
  ├─→ [Kick] → KICK (chain)
  ├─→ [Dash] → DASH (reposition)
  ├─→ [Expire] → MOVE (return to neutral)

KICK (0.35s recovery)
  ├─→ [Punch] → ATTACK (chain)
  ├─→ [Combo 2+] → COMBO_FINISHER
  └─→ [Expire] → MOVE

COMBO_FINISHER (0.5s recovery, nur nach 2+ Hits)
  ├─→ [Dash Cancel] → DASH (continue flow)
  └─→ [Expire] → MOVE

WALL_GRAB
  ├─→ [Jump] → JUMP (away from wall)
  ├─→ [Attack] → ATTACK (wall-attack)
  └─→ [Down] → MOVE (slide down, exit)

KNOCKBACK_HIT (0.4s, hilflos)
  └─→ [Recovery] → MOVE (kann nicht acted während)

LADDER
  ├─→ [Up/Down] → LADDER (climbing)
  ├─→ [Jump] → JUMP (absprung)
  └─→ [Exit] → MOVE
```

---

## 2. Combat System

### Attack Types & Properties

#### **Punch (Basis-Angriff)**
```
Reichweite: 15 Pixel
Schaden: 10 HP
Knockback: 100
Recovery: 0.25s
Animation: punch
Cancellations: → Kick, Dash, Jump
Beat-Timing: 0.5s vor Beat optimal
```

**Zweck:** Schnelle Combo-Start, hohe Frequency, wenig Knockback

**Visuelle Idee:**
```
Caprica schlägt schnell zu
Kleine Schlag-Effekt-Partikel
SFX: Punch-Sound
```

---

#### **Kick (Zweiter Combo-Hit)**
```
Reichweite: 25 Pixel
Schaden: 15 HP
Knockback: 250
Recovery: 0.35s
Animation: kick
Cancellations: → Punch, Combo (wenn 2+ Hits)
Beat-Timing: 0.75s vor Beat optimal
```

**Zweck:** Knockback-fokussiert, Gegner positioning

**Visuelle Idee:**
```
Caprica kickt mit Gewalt
Größere Effekt-Welle
SFX: Kick-Sound (tiefer als Punch)
```

---

#### **Combo Finisher (Guitar Smash)**
```
Voraussetzung: Nach 2+ Hits (Punch-Kick Combo)
Reichweite: 40 Pixel
Schaden: 30 HP (+ Beat-Bonus!)
Knockback: 400 (sehr hoch!)
Recovery: 0.5s
Animation: guitar_smash
Cancellations: → Dash (dashing recovery)
Beat-Timing: 1.0s Bonus (2x Multiplier!)
```

**Zweck:** Combo-Payoff, große Knockback für Environment-Interaction

**Visuelle Idee:**
```
Caprica schwingt Gitarre über ihrem Kopf
Große Schlag-Aura
Musik-Effekt: CRESCENDO!
SFX: Elektro-Gitarre-Schlag
Screen-Shake bei Peak-Damage
```

---

#### **Special: Wall Attack**
```
Nur möglich: Von Wall Grab
Reichweite: 30 (seitlich)
Schaden: 12 HP
Knockback: 200 (in Wand-Richtung)
Recovery: 0.3s
```

**Zweck:** Wall-Positioning zu taktischem Vorteil machen

---

### Beat-Timing Bonus System

**Musik treibt Damage an:**

```
Normal Attack Damage: 10 HP
Beat-Timed Attack: 15 HP (+50%)

Combo Finisher: 30 HP
Beat-Timed Finisher: 45 HP (+50%, dann 2.0x möglich!)
```

**Implementation:**

```
Wenn Angriff innerhalb 0.15s des Beat ausgeführt:
  ├─ Damage * 1.5
  ├─ Knockback * 1.2
  ├─ Coin-Reward * 1.5
  ├─ Visual: "PERFECT!" floating text
  └─ Audio: Zusätzlicher Musik-Ping
```

**Rhythmus-Zombies sind synchron:**
- Sie greifen AUCH auf dem Beat an
- Macht Audio + Enemy-Behavior transparent
- Spieler lernt Rhythmus schneller

---

## 3. Enemy System

### Gegner-Typen & Behavior

Caprica kämpft gegen verschiedene **SLOB-Zombie-Varianten**, jede mit eigenem Verhalten:

---

#### **Basic Zombie (Standard)**
```
HP: 30
Geschwindigkeit: 150
Angriff-Muster: Melee Swipe
Cooldown: 0.8s
Knockback-Widerstand: 1.0 (normal)
Loot: 5 Coins, 10% Kassette-Fragment
Schwierigkeit: ⭐
```

**Verhalten:**
1. Patrouille in Arena
2. Sieht Caprica → Charge
3. Greift mit Swipe an
4. Wartet auf Cooldown
5. Wiederholt

**Taktik gegen:**
- Einfach Punsch-Kick-Kombo
- Knockback in Umgebung

---

#### **Spitter Zombie (Range-Gegner)**
```
HP: 25
Geschwindigkeit: 120
Angriff-Muster: Projectile Spit
Reichweite: 300 (long!)
Cooldown: 1.0s
Knockback-Widerstand: 0.8 (leicht zu schieben)
Loot: 8 Coins
Schwierigkeit: ⭐⭐
```

**Verhalten:**
1. Hält Distanz zu Caprica (300+)
2. Spuckt Projektile
3. Flieht wenn Caprica zu nah
4. Sicherheits-Radius: 200

**Taktik gegen:**
- Dash zum Gegner (schnell!)
- Doppel-Jump um Projektile auszuweichen
- Kein Knockback-Leverage möglich (leicht)

---

#### **Tank Zombie (Heavy)**
```
HP: 80 (viel!)
Geschwindigkeit: 80 (langsam)
Angriff-Muster: Heavy Slam
Cooldown: 1.5s
Knockback-Widerstand: 0.5 (schwer zu schieben!)
Rüstung: 0.7 (30% Damage-Reduction)
Loot: 15 Coins, Waffen-Upgrade möglich
Schwierigkeit: ⭐⭐⭐
```

**Verhalten:**
1. Langsamer Charge
2. Wartet auf Caprica
3. Heavy Slam (big damage, long wind-up)
4. Lange Cooldown (leicht zu punish)

**Taktik gegen:**
- Viele Hits nötig (Rüstung!)
- Combo-Finisher für maximalen Knockback
- Wall-Grab zum Warten auf Slam
- Knockback in Wände/Fallen

---

#### **Runner Zombie (Schnell & Schwach)**
```
HP: 15 (niedrig!)
Geschwindigkeit: 250 (sehr schnell!)
Angriff-Muster: Dash Attack
Cooldown: 0.5s (kurz!)
Knockback-Widerstand: 1.5 (leicht zu schieben)
Loot: 3 Coins, 5% Speed-Boost
Schwierigkeit: ⭐⭐
```

**Verhalten:**
1. Dashing hin und her
2. Zufällige Dash-Attacks
3. Schnell, aber unberechenbar
4. Leicht zu KO wenn getroffen

**Taktik gegen:**
- Double-Jump um Dashes auszuweichen
- Ein guter Kick genügt zum KO
- Knockback sehr effektiv
- Tempo-Verlauf trainiert Rhythmus

---

#### **Rhythm Zombie (Beat-Synchron)**
```
HP: 40
Geschwindigkeit: 180
Angriff-Muster: Beat-Synchronized Attack
Timing: IMMER auf dem Beat!
Cooldown: 1 Beat (musicbpm dependent)
Knockback-Widerstand: 0.9
Loot: 10 Coins, 20% Kassette-Fragment
Schwierigkeit: ⭐⭐⭐
Besonderheit: VISUELLER TELEGRAPH!
```

**Verhalten:**
1. Beobachtet Caprica
2. Visuelle Tell: Körper leuchtet auf, Auge glüht
3. Genau auf Beat: Angriff!
4. Wiederholt nach Cooldown

**Taktik gegen:**
- Rhythmus LERNEN (Audio + Visual)
- Wall-Grab um Beat zu warten
- Doppel-Jump beim Telegraph
- Beat-timed Counter-Attack für Bonus

**Warum diese Gegner?**
- Trainiert Spieler, Musik zu HÖREN
- Macht Audio zur Game-Mechanik
- Verstärkt Musik-Crescendo

---

## 4. Arena-Design & Wave-System

### Philosophie
**Keine Precision-Jump-Rätsel!**

Stattdessen: **Offene Combat-Arenen** mit
- Plattformen für Positioning
- Wände für Wall-Grab Strategien
- Knockback-Leverage (Gegner in Hindernisse)
- Musik-synchrone Spawns

---

### Arena Layout Beispiel: Combat Arena 1

```
┌─────────────────────────────────────────────────┐
│              COMBAT ARENA 1                      │
│                                                  │
│  [Wall]          Platform            [Ladder]   │
│    ║               ▲                     ║      │
│    ║              ▼▼▼                    ║      │
│    ║            ╔════╗                   ║      │
│    ║            ║    ║                   ║      │
│    ║    ╔════════╝    ╚════════╗        ║      │
│    ║    ║                      ║        ║      │
│    ║ [OPEN ARENA FLOOR]        ║        ║      │
│    ║ (600x300)                 ║        ║      │
│    ║    ║       [Spawn]        ║        ║      │
│    ║    ║         [S]          ║        ║      │
│    ║    ║                      ║        ║      │
│    ║    ╚════════╗    ╔════════╝        ║      │
│    ║            ║    ║                   ║      │
│    ║            ╚════╝    Knockback      ║      │
│    ║                       Wall          ║      │
│    ║                                     ║      │
│  [Exit Portal] ─────────────────────────→      │
│                                                  │
└─────────────────────────────────────────────────┘
```

**Gegner-Spawns:**
- [S] = Spawn-Punkt
- Wave 1: 3x Basic Zombie (nacheinander)
- Wave 2: 2x Basic + 1x Runner
- Wave 3: 1x Tank + 2x Rhythm

---

### Wave-System (3 Waves pro Arena)

#### **Wave 1: Warm-up**
```
Gegner: 3x Basic Zombie (sequenziell)
Spawn-Interval: 2 Sekunden
Zeit-Limit: 45 Sekunden
Musik-Intensität: Drums + Bass (110 BPM)
Belohnung: 2 Coins pro Kill, 15 Coins Wave-Bonus
Lore: "Erste Welle schwacher Zombies"
```

**Gameplay-Zweck:** Spieler warm machen, Kombos üben

---

#### **Wave 2: Varianz einführen**
```
Gegner: 2x Basic + 1x Runner Zombie
Spawn-Interval: 2.5 Sekunden
Zeit-Limit: 60 Sekunden
Musik-Intensität: Add Guitar Layer (same BPM, 110)
Belohnung: 3 Coins pro Kill, 25 Coins Wave-Bonus, +1 Kassette-Fragment (5%)
Lore: "Schnellere Varianten, weniger Kontrolle nötig"
```

**Gameplay-Zweck:** Agiles Movement trainieren

---

#### **Wave 3: Challenge**
```
Gegner: 1x Tank + 2x Rhythm Zombie
Spawn-Interval: 3 Sekunden
Zeit-Limit: 90 Sekunden
Musik-Intensität: Add Vocals + Crescendo (115 BPM)
Belohnung: 5 Coins pro Kill, 50 Coins Wave-Bonus, Waffen-Upgrade
Lore: "Die stärksten Zombies, Musik rauscht!"
```

**Gameplay-Zweck:** Alles zusammen: Positioning, Beat-Timing, Knockback-Leverage

---

### Music Intensity Progression

```
WAVE 1 (Intro):
  Schlagzeug + Bass
  Tempo: 110 BPM
  Visual: Schwarzer Hintergrund, rote Linien

WAVE 2 (Build):
  + Gitarre-Layer (rhythmisch)
  Tempo: 110 BPM
  Visual: Farben werden kräftiger

WAVE 3 (Crescendo):
  + Vocals
  + Schnellere Drum-Pattern
  Tempo: 115 BPM
  Visual: EXPLOSION an Farben, Screen-Shake
```

**Wenn Wave erfolgreich:**
→ Musik erreicht Peak
→ Portal öffnet sich
→ Nächste Arena

---

## 5. Combat Flow - Praktisches Beispiel

### Szenario: Caprica vs Wave 1

```
SETUP:
└─ 3 Basic Zombies spawnen nacheinander

ZOMBIE 1 KILL:
  1. Zombie spawnt [S]
  2. Caprica sieht ihn → Move (strafing rechts)
  3. Zombie charges
  4. Caprica: DASH (500 spd, schneller!)
  5. Caprica: PUNCH (10 dmg, 100 knockback)
  6. Zombie wird leicht zurückgestoßen
  7. Caprica: KICK (15 dmg, 250 knockback)
  8. Zombie wird gegen Wand geworfen!
  9. Caprica kann COMBO_FINISHER (zu früh, erst 2 Hits!)
  10. Zombie-HP: 30 - 10 - 15 = 5 HP
  11. Caprica: PUNCH (10 dmg, letzterer Hit)
  12. Zombie KO!

  ✓ Reward: 5 Coins + Cassette 10% chance

ZOMBIE 2 vs SPITTER (unerwartet):
  [Szenario ändert sich]
  → Caprica muss Wall-Grab zum Ausweichen verwenden
  → Double-Jump um Spit-Angriff zu vermeiden
  → Close-Quarters Dash-Angriff nötig

ZOMBIE 3 (Runner):
  → Musik intensity steigt!
  → Rhythm-Tempo wird schneller (Beat-Timing wichtig!)
  → Caprica muss Beat-Timing für +50% Damage nutzen
  → Finale COMBO_FINISHER on Beat: 45 HP damage!
  → Runner KO in 1-2 Combos

WAVE 1 CLEARED:
  → Musik-Peak
  → Screen-Flash
  → Reward: 15 Coins + 1x Kassette-Fragment (möglich)
  → Countdown to Wave 2...
```

---

## 6. Progression & Loot System

### Coin-System
```
Basic Zombie kill: 5 Coins
Spitter kill: 8 Coins
Runner kill: 3 Coins
Tank kill: 15 Coins
Rhythm kill: 10 Coins

Beat-Timed Bonus: x1.5 Coins
Wave Completion Bonus: 15-50 Coins (pro Wave)

Cassette Fragment: Findet zufällig (5-20% Chancen)
```

**Verwendung:**
- Coins: Upgrades kaufen (Health, Damage, Speed)
- Cassettes: Story unlock, Musik-Sammlung

---

### Waffen-Upgrades (nach Arena-Clearing)

Nach Wave 3 erhält Caprica möglich neue Waffe:

```
GITARREN-TYPES:

1. Electric Guitar (Standard)
   └─ Punch/Kick normal

2. Axe Guitar
   └─ Kicks deal 2x Knockback
   └─ Slower recovery (0.5s)
   └─ More aggressive

3. Chord-Strum Guitar
   └─ Attack hat Area-of-Effect (Radius 50)
   └─ Hits multiple enemies
   └─ Lower single-target damage (12 vs 15)

4. Flamethrower Guitar
   └─ Attacks have DOT (damage over time)
   └─ Slow projectile-like flame
   └─ Can ignite arena
```

---

## 7. Bewegungs-Metriken & Feel

### Geschwindigkeiten (Pixel/Sekunde)
```
Walk/Move: 200 px/s
Dash: 500 px/s (2.5x faster)
Jump: 200 units (Godot physics)
Double Jump: 200 units (full recovery)
Wall Slide: 100 px/s (langsam)
Ladder: 100 px/s (steuerbar)
```

### Recovery Times (Recovery = Zeit bis nächster Move möglich)
```
Punch: 0.25s (schnell, für Combos)
Kick: 0.35s (etwas länger)
Combo Finisher: 0.5s (lang, aber cancellable mit Dash)
Dash: Kein Recovery (direkt in nächste Action)
Wall Grab: Sofort interruptible (flexibel)
```

### Visual Polish
```
Every Hit:
  ├─ Screen-Shake (gering)
  ├─ Floating Damage Number
  ├─ Hit-Spark Effekt
  └─ Audio Feedback (Punch/Kick/Smash SFX)

Combo-Counter:
  ├─ Visible Counter (links oben)
  ├─ Combo-Timer (wie lange Kombo valid?)
  └─ Bonus-Notiz bei Beat-Timing
```

---

## 8. Spieler-Erlebnis Timeline

### Arena 1-3: Learning Phase
```
Spieler lernt:
├─ Basic Movement (Dash, Jump, Walk)
├─ Attack-Recovery Timing
├─ Enemy-Patterns (Basic, Spitter, Runner)
├─ Beat-Timing Concept (visuell + audio)
└─ Wall-Grab Strategien
```

### Arena 4-6: Mastery Phase
```
Spieler meistert:
├─ Combo-Chaining
├─ Environment-Leverage (Knockback in Objekte)
├─ Rhythm-Zombies (Beat-Timing essentiell)
├─ Position-Management (mehrere Gegner)
└─ Waffen-Upgrades
```

### Boss Battle: Crescendo Phase
```
Finale Musikstück:
├─ Alle Instrumente
├─ Volle Intensität
├─ Boss hat mehrteilige Attack-Pattern
├─ Beat-Timing = Überleben
└─ Epische Finale
```

---

## 9. Design Philosophy Summary

### Was macht Caprica's Combat Einzigartig?

1. **Musik ist Mechanic**
   - Nicht nur OST, sondern Game-System
   - Rhythmus-Zombies trainieren Audio-Awareness
   - Beat-Timing = Reward-Loop

2. **Kein Precision-Platforming**
   - Bewegung = Combat-Tool
   - Knockback = Umgebungs-Interaktion
   - Flow-State statt Frustration

3. **Aggressive Momentum**
   - Alles ist cancellable
   - Schnelle Recovery-Times
   - Belohnt aktives Spielen

4. **Visual Feedback**
   - Jede Action hat Konsequenz
   - Screen-Shake, Explosionen, Farben
   - Musik + Visuals = synergetisches Erlebnis

---

## 10. Next Steps - Implementation Roadmap

```
Phase 1: Core Movement
  ├─ State Machine (Idle, Move, Dash, Jump, etc.)
  ├─ Animation System
  └─ Input Handling

Phase 2: Basic Combat
  ├─ Punch/Kick Attacks
  ├─ Combo-System (Cancellations)
  ├─ Knockback Physics
  └─ Hit-Feedback

Phase 3: Enemies
  ├─ Basic Zombie
  ├─ Behavior-Trees
  ├─ Spawning-System
  └─ Wave-Manager

Phase 4: Music Integration
  ├─ Beat-Detection
  ├─ Damage-Multiplier on Beat
  ├─ Rhythm-Zombies
  └─ Music Intensity Scaling

Phase 5: Polish & Arena Design
  ├─ Multiple Arenas
  ├─ Visual Effects
  ├─ Audio Mix
  └─ Level-Progression
```

---

## Glossary

**Beat-Timing:** Angriff wird innerhalb 0.15s eines Musik-Beats ausgeführt (+50% Damage)

**Cancellation:** Aktueller Move kann unterbrochen werden um neuen Move zu starten (z.B. Punch → Kick)

**Knockback:** Kraft, die Gegner zurückschleudert (in Pixel/Sekunde)

**Recovery:** Zeit nach Action bevor nächste Action möglich (meist 0.25-0.5s)

**Wave:** Gruppe von Gegnern die sequenziell spawnen (3 Waves pro Arena)

**Combo:** Mehrere Angriffe nacheinander (min. 2 für Finisher)

**SLOB:** Strange Living Organisms, Blutleere Zombie-Typen

---

**Erstellt:** 30. Dezember 2025
**Für:** CapricaGame - Rockstar Combat Platformer
