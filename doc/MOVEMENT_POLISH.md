# Movement Polish - Priorität VOR Combat

## Überblick

**Grundprinzip:** Ein Spiel fühlt sich besser an wenn das Movement flüssig wahrgenommen wird, bevor das Combat-System entwickelt wird.

Egal wie brillant das Combat-Design ist – wenn sich Caprica beim Bewegen **spongy, laggy oder ungefällig** anfühlt, wird das ganze Spiel frustrierend.

**Priorität:** Movement Polish **MUSS** abgeschlossen sein, bevor wir Combat-Features implementieren.

---

## 1. Was bedeutet "Flüssiges Movement"?

### ✅ Flüssiges Movement-Feel

```
EIGENSCHAFTEN:
├─ Sofortige Input-Reaktion
│  └─ Keine Verzögerung zwischen Button-Press und Bewegung
│
├─ Smooth Animationen
│  └─ Keine Jank-Frames, keine Flimmering
│
├─ Zufriedenstellendes Feedback
│  ├─ Visual Feedback (Screen-Shake, Dust, Trails)
│  ├─ Audio Feedback (Schritte, Jump-Sound, Landing)
│  └─ Haptic Feedback (Controller-Rumble, optional)
│
├─ Konsistente Physik
│  └─ Jump-Höhe ist immer gleich, nicht zufällig
│
├─ Natürliches Momentum
│  ├─ Movement fühlt sich nicht "rutschhig" an
│  ├─ Movement fühlt sich nicht "steif" an
│  └─ Übergänge sind organisch
│
├─ Zuverlässige Recovery-Moves
│  └─ Doppel-Jump, Wall-Grab funktionieren zu 100%
│
└─ Befriedigende "Oomph"
   └─ Movement hat GEWICHT und POWER
```

### ❌ Schlechtes Movement-Feel

```
PROBLEME:
├─ Input-Lag
│  └─ Spieler drückt Jump, aber es verzögert sich
│
├─ Ruckelige Animationen
│  └─ Animation-Frames sind ungleichmäßig
│
├─ Fehlende Feedback
│  └─ Bewegungen fühlen sich "leer" an
│
├─ Inkonsistente Physik
│  └─ Manchmal höher, manchmal niedriger Jump
│
├─ Zu rutschig
│  └─ Richtungswechsel sind schwer/verzögert
│
├─ Zu steif
│  └─ Bewegungen fühlen sich mechanisch an
│
└─ Billige Recovery-Moves
   └─ Double-Jump funktioniert nicht zuverlässig
```

---

## 2. Movement Polish Checkliste

### Phase 1: Input Responsiveness (Sofort-Feedback)

```
□ DASH
  ├─ Startet sofort nach Button-Press (kein Delay)
  ├─ Wird sofort unterbrochen wenn Button losgelassen
  ├─ Kann mit anderen Buttons gecancelled werden
  └─ Momentum bleibt nach Dash erhalten

□ JUMP
  ├─ Startet sofort, animiert die komplette Auf/Ab-Bewegung
  ├─ Button-Timing ändert Jump-Höhe (kurz = kurz, lang = hoch)
  ├─ Coyote-Jump funktioniert zuverlässig (~0.15s Fenster)
  └─ Double-Jump reagiert sofort auf zweiten Button-Press

□ MOVEMENT (Walk/Strafe)
  ├─ Instant bei Button-Press (keine Acceleration-Verzögerung)
  ├─ Instant Richtungswechsel (von links zu rechts)
  ├─ Blending zwischen idle/run-animationen ist smooth
  └─ Stop-Bewegung ist schnell (keine Deceleration-Verzögerung)

□ WALL GRAB
  ├─ Registriert sofort wenn auf Wand gesprungen wird
  ├─ Gibt sofort Feedback (Sound, Animation-Wechsel)
  └─ Kann sofort mit Jump/Attack interagiert werden

□ LADDER
  ├─ Enter/Exit sind instant (kein "stuck" Gefühl)
  ├─ Auf/Ab ist sofort kontrollerbar
  └─ Jump vom Ladder ist sofort möglich
```

### Phase 2: Animation & Visuals (Smoothness)

```
□ IDLE ANIMATION
  ├─ Loop ist smooth (keine Flimmering am Anfang/Ende)
  ├─ Timing ist konsistent (immer gleiche Duration)
  ├─ Übergang von Run zu Idle ist seamless
  └─ Sprite-Flip ist instant (Richtungswechsel)

□ RUN/WALK ANIMATION
  ├─ Cycle-Speed passt zu Bewegungs-Speed
  ├─ Keine Frame-Drops (alles ist 60 FPS)
  ├─ Footstep-Sounds sind synchronisiert
  └─ Übergang zu Jump/Dash ist smooth

□ JUMP ANIMATION
  ├─ Aufstieg und Abstieg sind unterschiedlich (Arcade-Gefühl)
  ├─ Peak-Frame signalisiert Höhepunkt
  ├─ Landing-Animation ist knackig (ca 0.1s)
  └─ Air-Idle-Animation während Luftflug

□ DASH ANIMATION
  ├─ Schnelle, polierte Animation (0.15s Dash-Duration)
  ├─ Bewegungs-VFX (Dust, Motion-Lines, Trail)
  ├─ Sound wird synchronisiert
  └─ Übergänge in/aus Dash sind smooth

□ WALL GRAB ANIMATION
  ├─ Stabile Pose (Caprica hängt sicher)
  ├─ Slide-Animation wenn runterrutscht
  ├─ Jump-Animation wenn abspringt
  └─ Keine "Zittern"-Artefakte

□ LADDER ANIMATION
  ├─ Climb-Cycle synchronisiert mit Bewegungs-Speed
  ├─ Up/Down sind unterschiedliche Animationen
  └─ Exit-Animation ist smooth
```

### Phase 3: Physics Feel (Kontrolle)

```
□ JUMP-MECHANIK
  ├─ Jump-Höhe: ca 200 units (befriedigend ohne zu lang)
  ├─ Aufstieg vs Abstieg: Aufstieg schneller (Float am Top)
  ├─ Air-Control: Kann während Jump noch steuern
  ├─ Jump fühlt sich gewichtig an (nicht "floaty")
  └─ Fallgeschwindigkeit ist moderat (zu schnell = frustrating)

□ DOUBLE JUMP
  ├─ Zweiter Jump hat vollen Boost (200 units)
  ├─ Recovery-Nutzen ist deutlich (kann Gegner ausweichen)
  ├─ Fühlt sich "mächtig" an (nicht als schwächer wahrgenommen)
  └─ Cooldown existiert nicht (beliebig oft per Level)

□ DASH
  ├─ Geschwindigkeit: 500 px/s (aggressiv, nicht zu schnell)
  ├─ Momentum bleibt erhalten (Inertia)
  ├─ Kann während Dash nicht steuern (Commitment-Feel)
  ├─ Cooldown ist kurz (0.3s, für schnelle Sequences)
  └─ Fühlt sich wie "Offensive Move" an

□ MOVEMENT-SPEED
  ├─ Walk/Strafe: 200 px/s (schnell genug)
  ├─ Beschleunigung: Instant (kein Acceleration-Delay)
  ├─ Verzögerung: Instant (kein Deceleration-Lag)
  └─ Richtungswechsel: Sofort (100% responsiv)

□ GRAVITY & FALL
  ├─ Gravity fühlt sich "richtig" an (nicht zu leicht, nicht zu schwer)
  ├─ Fallgeschwindigkeit ist moderat-schnell (kontrollierbar)
  ├─ Terminal-Velocity wird schnell erreicht
  └─ Air-Control bleibt während Fall erhalten
```

### Phase 4: Feedback & Polish (Zufriedenheit)

```
□ VISUELLES FEEDBACK
  ├─ Jump Start
  │  └─ Kleine Screen-Shake (2-3 pixel)
  │  └─ Partikeln (Dust aufsteigen)
  │
  ├─ Jump Landing
  │  └─ Kleine Screen-Shake
  │  └─ Landing-Dust Effekt
  │  └─ Animation ist knackig
  │
  ├─ Dash Start
  │  └─ Motion-Lines / Trail-Effekt
  │  └─ Größere Screen-Shake
  │  └─ "Aggressive" Visuals
  │
  ├─ Wall-Grab
  │  └─ Kratz-Partikel
  │  └─ Wand-Kontakt Sparkles
  │  └─ Caprica-Pose ändert sich
  │
  └─ Richtungswechsel
     └─ Sprite-Flip ist instant + visuelle "Zwinge"

□ AUDIO FEEDBACK
  ├─ Jump-Start
  │  └─ Kurzer Pitch-Up Sound (20ms)
  │
  ├─ Jump-Landing
  │  └─ Dumpfer Landing-Sound
  │  └─ Pitch variiert je nach Höhe
  │
  ├─ Dash
  │  └─ Schneller "Whoosh" Sound
  │  └─ Aggressive Effekt
  │
  ├─ Wall-Grab
  │  └─ Kratzer/Scrape Sound
  │  └─ Halt-Sound (kurz)
  │
  ├─ Schritte (während Walk)
  │  └─ Rhythmische Footstep-Sounds
  │  └─ Synchronisiert mit Animations-Cycle
  │
  └─ Allgemein
     └─ Alle Sounds sind "knackig" (nicht dumpf)
     └─ Mixing ist clear (keine Lautstärken-Konflikte)

□ HAPTIC FEEDBACK (Optional, für Controller)
  ├─ Jump: Kurzes Rumble (20ms)
  ├─ Landing: Längers Rumble (50ms)
  ├─ Dash: Aggressives Rumble (100ms)
  └─ Wall-Grab: Subtiles Rumble (30ms)
```

### Phase 5: Edge Cases (Zuverlässigkeit)

```
□ JUMP AUF BEWEGENDE PLATTFORMEN
  ├─ Platform-Velocity wird übernommen
  ├─ Jump-Höhe ist nicht betroffen
  └─ Landing ist stabil

□ KNOCKBACK-RECOVERY
  ├─ Doppel-Jump funktioniert während Knockback
  ├─ Wall-Grab kann während Knockback aktiviert werden
  ├─ Landing ist sauber nach Knockback
  └─ Keine "Stuck" Zustände möglich

□ LADDER-INTERAKTIONEN
  ├─ Enter von unten ist smooth
  ├─ Enter von oben ist smooth
  ├─ Exit nach oben/unten funktioniert
  ├─ Jump vom Ladder ist sofort möglich
  └─ Richtungswechsel während Ladder ist responsiv

□ WALL-GRAB EDGE CASES
  ├─ Kleine Wände (schmaler als Caprica)
  ├─ Große Wände (viel höher als Caprica)
  ├─ Wand-Ecken (Wall-zu-Plattform Übergänge)
  ├─ Moving Walls (wenn Wand sich bewegt)
  └─ Keine "Stuck" Zustände

□ RICHTUNGSWECHSEL
  ├─ Während Jump (Facing-Wechsel)
  ├─ Während Dash (Momentum-Wechsel)
  ├─ Während Wall-Grab (Flip ist instant)
  └─ Rapid Input (Links-Rechts-Links schnell) ist responsiv

□ MULTIPLE INPUT SEQUENZEN
  ├─ Jump → Dash → Jump funktioniert smooth
  ├─ Dash → Wall-Grab → Jump funktioniert
  ├─ Walk → Jump → Double-Jump ist seamless
  └─ Komplexe Kombinationen sind fehlerlos
```

---

## 3. Praktische Bewegungs-Tests

### Test 1: Input Lag Check (2 Minuten)

**Ziel:** Überprüfen ob Inputs sofort registriert werden

**Durchführung:**
1. Spiel starten (Play Mode)
2. **Dash Tests:**
   - Rechts-Taste drücken → Sofort Dash?
   - Dash unterbrechen → Sofort Stop?
   - Während Dash Jump drücken → Sofort Jump?

3. **Jump Tests:**
   - Jump-Taste kurz drücken → Kurzer Jump?
   - Jump-Taste lange halten → Höherer Jump?
   - Während Jump rechts drücken → Sofort Bewegung?

4. **Feeling:**
   - ✅ Fühlt sich "tight" an? (responsiv)
   - ✅ Keine Verzögerung spürbar?
   - ✅ Übernahme-Feeling (Caprica gehorcht sofort)?

### Test 2: Animation Smoothness (3 Minuten)

**Ziel:** Überprüfen ob Animationen smooth sind

**Durchführung:**
1. Langsam laufen + visuelle Animationen beobachten
2. Jump + Landing-Animation beobachten
3. Dash-Animation beobachten (Anfang + Ende)
4. Wall-Grab-Animation beobachten
5. Richtungswechsel-Animation beobachten

**Feeling:**
- ✅ Keine Frame-Drops?
- ✅ Keine Jank-Frames?
- ✅ Übergänge sind smooth (kein Flimmern)?
- ✅ Animationen sind "poliert" (nicht unvollständig)?

### Test 3: Physics Feel (5 Minuten)

**Ziel:** Überprüfen ob Physics sich "richtig" anfühlen

**Durchführung:**
1. **Jump-Höhe testen:**
   ```
   Walk → Jump auf Plattform
   Können wir die Plattform erreichen?
   Jump-Höhe ist befriedigend?
   ```

2. **Doppel-Jump testen:**
   ```
   Jump → Double-Jump → Können wir weitere Höhe gewinnen?
   Double-Jump fühlt sich "wertvoll" an?
   ```

3. **Dash-Feel testen:**
   ```
   Strafe → Dash → Momentum bleibt erhalten?
   Dash-Geschwindigkeit ist "aggressiv"?
   Fühlt sich wie "Offensive Move" an?
   ```

4. **Fall-Feel testen:**
   ```
   Jump → Nichts drücken → Fallgeschwindigkeit ist moderat?
   Können wir während Fall noch steuern?
   Landing-Impact ist zufriedenstellend?
   ```

### Test 4: Feedback Satisfaction (3 Minuten)

**Ziel:** Überprüfen ob Feedback zufriedenstellend ist

**Durchführung:**
1. **Visual Feedback:**
   - Jump: Sehen wir Screen-Shake + Dust?
   - Landing: Sehen wir Landing-Effekt?
   - Dash: Sehen wir Motion-Lines?

2. **Audio Feedback:**
   - Jump: Hören wir Jump-Sound?
   - Landing: Hören wir Landing-Sound?
   - Dash: Hören wir Whoosh-Sound?
   - Walk: Hören wir Footsteps?

3. **Feeling:**
   - ✅ Feedback fühlt sich "solide" an?
   - ✅ Feedback ist nicht zu laut/zu leise?
   - ✅ Feedback macht Spaß (nicht nervig)?

### Test 5: Komplexe Sequenzen (5 Minuten)

**Ziel:** Überprüfen ob komplexe Movements reibungslos funktionieren

**Durchführung:**
```
Sequenz 1: Walk → Jump → Double-Jump → Landing
Sequenz 2: Dash → Jump → Wall-Grab → Jump-Off
Sequenz 3: Jump → Dash-Mid-Air → Landing → Strafe
Sequenz 4: Walk → Ladder-Up → Jump → Double-Jump
Sequenz 5: Run → Dash → Double-Jump → Wall-Grab → Jump
```

**Feeling:**
- ✅ Alles funktioniert ohne Fehler?
- ✅ Übergänge sind smooth?
- ✅ Keine Clipping/Stuck-Zustände?
- ✅ Movement fühlt sich "meisterbar" an?

---

## 4. Prioritäts-Ranking (Was ist wichtigst?)

### 🔴 CRITICAL (Muss perfekt sein)
```
1. Input-Responsiveness
   └─ Alles andere hängt davon ab

2. Physics Feel (Jump, Gravity, Falling)
   └─ Basis für alles weitere

3. Basic Animations (Idle, Run, Jump)
   └─ Wird ständig gesehen
```

### 🟠 HIGH (Sehr wichtig)
```
4. Wall-Grab Zuverlässigkeit
   └─ Must-Have Recovery-Tool

5. Landing-Feedback
   └─ Zuverlässig + Zufriedenstellung

6. Dash-Feel
   └─ Wichtig für Combat-Flow
```

### 🟡 MEDIUM (Wichtig aber nicht kritisch)
```
7. Double-Jump Feel
   └─ Nice-to-Have Recovery

8. Audio Feedback
   └─ Macht Spaß, aber nicht essentiell

9. Visual Effects
   └─ Polish, aber nicht game-breaking
```

---

## 5. Häufige Movement-Probleme & Lösungen

### Problem: "Zu rutschhig" (Slippery)
**Symptom:** Caprica rutscht überall hin, kann nicht stoppen

**Ursachen:**
- Friction ist zu niedrig
- Deceleration ist zu langsam
- Air-Control fehlt

**Lösung:**
- Erhöhe Friction in Physics2D
- Füge sofortige Deceleration ein
- Erlaube Air-Control während Jump

---

### Problem: "Zu steif" (Floaty)
**Symptom:** Caprica fühlt sich roboterhaft an

**Ursachen:**
- Gravity ist zu niedrig
- Jump-Duration ist zu lang
- Keine Momentum-Übertragung

**Lösung:**
- Erhöhe Gravity
- Verkürze Jump-Höhe
- Behalte Momentum nach Actions

---

### Problem: "Input-Lag"
**Symptom:** Knopfdruck verzögert sich

**Ursachen:**
- _physics_process() ist zu langsam
- Input-Polling ist nicht schnell genug
- Animationen blocken Input

**Lösung:**
- Input in _input() verarbeiten (nicht _physics_process())
- Animationen nicht blocken
- Priorisiere Input-Verarbeitung

---

### Problem: "Jump fühlt sich schwach"
**Symptom:** Jump reicht nicht hoch genug

**Ursachen:**
- Jump-Velocity ist zu niedrig
- Gravity ist zu hoch
- Jump-Button-Fenster ist zu kurz

**Lösung:**
- Erhöhe Initial-Jump-Velocity
- Reduziere Gravity (oder variiere sie)
- Vergrößere Jump-Button-Fenster

---

### Problem: "Landing fühlt sich hart"
**Symptom:** Landing ist ruckhaft/unangenehm

**Ursachen:**
- Landing-Impact ist zu groß
- Landing-Animation ist zu kurz
- Keine Landing-Verzögerung

**Lösung:**
- Sanfte Landing-Animation (0.1s)
- Kleine Screen-Shake (2-3 px, nicht 10px)
- Brief Landing-Pause vor Nächstem Move

---

## 6. Testing Workflow

### Tägliches Movement Testing
```
□ Jede Änderung testen (Play Mode)
□ Alle 5 Test-Szenarien durchlaufen
□ Dokumentieren ob besser/schlechter/gleich
□ Niemals "blind" Changes committen
```

### Vor Combat-Implementierung
```
□ Alle 5 Phasen (Input, Animation, Physics, Feedback, EdgeCases) abgeschlossen
□ Alle Test-Szenarien bestanden
□ Movement fühlt sich "professional" an
□ Keine Known Issues
```

---

## 7. Messbare Metriken

### Input Responsiveness
```
Standard: Input sollte innerhalb 1 Frame (16ms @ 60FPS) registriert werden
Ziel: 0-1 Frame Delay (sofort)
```

### Animation Smoothness
```
Standard: 60 FPS konstant, keine Frame-Drops
Ziel: 60 FPS @ alle Animationen
```

### Physics Consistency
```
Standard: Jump-Höhe ist immer gleich (±5%)
Ziel: Jump-Höhe ist konsistent auf den Pixel
```

### Movement Speed
```
Walk: 200 px/s
Dash: 500 px/s
Target: ±10% Variation maximal
```

---

## 8. Checkliste zum Abhaken

```
[ ] Input Responsiveness Phase ABGESCHLOSSEN
[ ] Animation & Visuals Phase ABGESCHLOSSEN
[ ] Physics Feel Phase ABGESCHLOSSEN
[ ] Feedback & Polish Phase ABGESCHLOSSEN
[ ] Edge Cases Phase ABGESCHLOSSEN

[ ] Alle 5 Test-Szenarien BESTANDEN
[ ] Keine Known Issues VORHANDEN
[ ] Movement fühlt sich PROFESSIONAL an
[ ] Bereit für COMBAT-IMPLEMENTATION
```

---

**Status:** In Arbeit
**Priorität:** CRITICAL (vor Combat!)
**Ziel:** Movement-Feel = Professional + Zufriedenstellung

