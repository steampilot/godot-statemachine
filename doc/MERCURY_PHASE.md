# Development Roadmap - Mercury Phase (AKTIV)

**Status:** 🔵 Mercury Phase - Wir sind HIER

*Du lernst deine "Firsts" - die Fundamentals ohne Ablenkung*

---

## 🎯 Mercury Phase: "Learning Our Firsts"

**Zeitrahmen:** Woche 1-3
**Philosophie:** Eine Sache nach der anderen. Jede Mercury-Mission meistert **ein Core-System in vollständiger Isolation**.

**Deliverable am Ende:** Spielbare 1-Level-Demo mit:

- Caprica kann herumspringen
- Erster Gegner (Zombie)
- Erste Attack (Kick)
- Musik startet und spielt Beats
- Level-Wechsel funktioniert

### Mercury-Missions Übersicht

```
Mercury 0  → Sprite Animation Foundation  (PixelLab AI + Godot SpriteFrames)
Mercury 1  → Beat Detection        (Audio verstehen)
Mercury 2  → Intent Input System   (Input verstehen)
Mercury 3  → First Enemy           (Gegner verstehen)
Mercury 4  → Attack & Combo        (Combat verstehen)
Mercury 5  → Boss & Waves          (Boss-System verstehen)
Mercury 6  → Level Navigation      (Level-Wechsel verstehen)
```

Jede Mission: **Isoliert, fokussiert, spielbar.**

---

## 🔵 Mercury 0: Dein ERSTES - Sprite Animation Pipeline

**Learning Goal:** Wie kommen PixelLab-AI-generierte Animationen sauber und wiederholbar in Godot an?

**Was du lernst:**

- PixelLab-AI-Frames oder Sprite-Sheets exportieren
- Assets sinnvoll unter `res/Assets/Characters/` ablegen
- SpriteFrames in Godot einrichten
- Animationsnamen mit den Player-States synchron halten

**Konkrete Milestones:**

1. Caprica Idle-Animation ist als SpriteFrames-Animation spielbar.
2. Caprica Walk/Run ist als SpriteFrames-Animation spielbar.
3. Caprica Jump/Fall ist als SpriteFrames-Animation spielbar.
4. Erste Combat-Animation ist als SpriteFrames-Animation spielbar.
5. Ein Zombie nutzt dieselbe Pipeline mit eigenem Sprite-Set.

**Praktischer Anfang:**
→ **Siehe:** [ANIMATION_PIPELINE.md](ANIMATION_PIPELINE.md) ← **START HIER!**

Das ist der neue Einstieg für die Sprite-basierte Animationsarbeit.

---
**Wie lange?** 1-2 Tage für eine erste saubere Pipeline.

**DoD (Definition of Done):**

```gdscript
# In deinem Test-Script funktioniert:
caprica.play_animation("idle")      # Steht, atmet
caprica.play_animation("walk_left")  # Läuft links
caprica.play_animation("walk_right") # Läuft rechts
caprica.play_animation("jump")       # Springt auf und runter
```

→ **Siehe Details:** [ANIMATION_PIPELINE.md](ANIMATION_PIPELINE.md)

---

## 🔵 Mercury 1: Dein ERSTES - Beat Detection

**Learning Goal:** Wie bekomme ich aus einem Audio-Stream Beat-Informationen?

**Was du lernst:**

- Godot AudioBus + FFT Analysis (Frequenz-Daten)
- BPM erkennen aus Audio (oder manuell setzen)
- Beat-Events emittieren (Signale)
- Timing messen (±50ms Genauigkeit)

**Konkrete Milestones:**

1. ✅ AudioBus-Analysis Setup
2. ✅ BPM aus Sample-Song bestimmen
3. ✅ Beat-Pulse-Signal emittieren
4. ✅ Visueller Debug-Indicator (Beat auf Screen sichtbar)
5. ✅ Timing testen (Game feuert Event exakt auf dem Beat)

**Wie lange?** 2-3 Tage

**DoD (Definition of Done):**

```gdscript
# Beat-Detektion funktioniert:
beat_detector.on_beat.connect(_on_beat_detected)

func _on_beat_detected() -> void:
    print("BEAT!")  # Exakt im Takt
    # Screen flasht, Score erhöht sich, etc.
```

---

## 🔵 Mercury 2: Dein ERSTES - Intent Input System

**Learning Goal:** Wie entkopple ich Input von Game-Logic?

**Was du lernst:**

- Input-Polling in Input-Klasse isolieren
- Intent-Objekte / Intent-Enum erstellen
- Intent-Signale emittieren
- Verschiedene Input-Sources (Controller, Keyboard, AI) können gleiche Intents senden

**Konkrete Milestones:**

1. ✅ IntentEmitter-Klasse schreiben
2. ✅ MOVE, JUMP, ATTACK Intents definieren
3. ✅ Input-Polling funktioniert (D-Pad → MOVE Intent)
4. ✅ Signale emittieren bei jeder Intent
5. ✅ Mock-Spieler: AI kann gleiche Intents senden

**Wie lange?** 1-2 Tage

**DoD (Definition of Done):**

```gdscript
# Intent-System funktioniert:
intent_emitter.move.connect(_on_move_intent)
intent_emitter.jump.connect(_on_jump_intent)
intent_emitter.attack.connect(_on_attack_intent)

# Player abhängig von Intent, nicht von rohem Input
func _on_move_intent(direction: float) -> void:
    velocity.x = direction * speed
```

---

## 🔵 Mercury 3: Dein ERSTES - Gegner / Enemy

**Learning Goal:** Wie mache ich einen Gegner mit Health, Damage, Death?

**Was du lernst:**

- Component-basierte Architektur (HealthComponent)
- Collision-Detection (HurtBox, HitBox)
- Signals für State-Changes
- Enemy-Animation abspielen

**Konkrete Milestones:**

1. ✅ SLOB-Zombie Sprite-Set nutzt die PixelLab-AI-Pipeline aus Mercury 0
2. ✅ HealthComponent schreiben (take_damage, health_changed Signal)
3. ✅ Zombie spawnt in Level
4. ✅ Zombie-Health anzeigen (HUD oder Healthbar über Kopf)
5. ✅ Zombie stirbt mit Animation
6. ✅ DeathComponent entfernt Zombie nach Animation

**Wie lange?** 2-3 Tage

**DoD (Definition of Done):**

```gdscript
# Zombie funktioniert:
zombie.health.take_damage(5)           # -5 HP
print(zombie.health.current_hp)        # 15
zombie.health.health_changed.emit()    # Signal
zombie.die()                           # Death-Animation + Remove
```

---

## 🔵 Mercury 4: Dein ERSTES - Attack & Combo

**Learning Goal:** Wie registriere ich Hits? Wie funktioniert Beat-Timing Bonus?

**Was du lernst:**

- Hitbox/Hurtbox System (Area2D Collision)
- Hit-Registration mit Overlap-Detektion
- Beat-Timing Fenster (war Hit im Beat?)
- Damage-Berechnung (Base + Beat-Bonus)
- Combo-Counter (Fenster für Follow-up)

**Konkrete Milestones:**

1. ✅ Caprica Kick-Animation (nutzt Mercury 0)
2. ✅ Kick-Hitbox spawnt (0.2s - 0.4s während Animation)
3. ✅ Hit auf Zombie registrieren (health.take_damage)
4. ✅ Beat-Timing Bonus (+50% wenn Hit im Beat-Fenster)
5. ✅ Combo-Counter (nächster Hit möglich im 1.5s Fenster)
6. ✅ Damage-Zahlen auf Screen (visuelles Feedback)

**Wie lange?** 3-4 Tage

**DoD (Definition of Done):**

```gdscript
# Attack funktioniert:
caprica.play_animation("kick")
# → Hitbox spawnt automatisch
# → Zombie nimmt Damage
# → Wenn auf Beat: +50% Damage!
# → Combo-Fenster startet (Punch jetzt möglich)
```

---

## 🔵 Mercury 5: Dein ERSTES - Boss & Wave System

**Learning Goal:** Wie funktioniert progressive Musik + Boss-Encounter?

**Was du lernst:**

- Boss als stärkerer Gegner (mehr Health, andere Animationen)
- Music-Wave-System (Drums → +Guitar → +Vocals)
- Audio-Track Layer-Switching
- Wave-Events triggern (nach 20s nächste Welle)
- Visual Intensity Scaling

**Konkrete Milestones:**

1. ✅ Boss-Zombie (5x Health von Regular)
2. ✅ Boss-Animationen (aggressiver Idle, Attack)
3. ✅ Music startet: Wave 1 (Drums + Bass)
4. ✅ Nach 20s: Wave 2 (+Gitarre hinzufügen)
5. ✅ Nach weiteren 20s: Wave 3 (+Vocals)
6. ✅ Beat-Timing wird wichtiger (mehr Schaden möglich)
7. ✅ Boss-Defeat = Wechsel zum nächsten Level

**Wie lange?** 3-4 Tage

**DoD (Definition of Done):**

```gdscript
# Boss-Encounter funktioniert:
boss.spawn()  # Boss erscheint
music.play("boss_song")
# → 20s: Nur Drums+Bass
# → +20s: +Guitar-Track
# → +20s: +Vocals
# → Beat-Timing immer kritischer
# → Boss besiegt = NextLevel
```

---

## 🔵 Mercury 6: Dein ERSTES - Level Navigation & Portal

**Learning Goal:** Wie funktioniert Level-Wechsel mit Portalen?

**Was du lernst:**

- Scene-Management (Level 1 → Level 2)
- Portal als Trigger-Area
- Spawn-Points
- Fade-To-Black Transition
- Puppet-Manager Basis (optionaler Visual-Polish)

**Konkrete Milestones:**

1. ✅ Level 1 Scene (Exploration → Combat → Boss)
2. ✅ Portal am Ende von Level 1
3. ✅ Spawn-Point in Level 2
4. ✅ Portal-Touch → Fade → Level 2 Spawn
5. ✅ Camera folgt Caprica in Level 2
6. ✅ Musik nahtlos weitermachen (oder fade)

**Wie lange?** 2-3 Tage

**DoD (Definition of Done):**

```gdscript
# Level-Wechsel funktioniert:
caprica.enter_portal()
# → Fade-to-Black
# → Level 2 wird geladen
# → Caprica spawnt am Spawn-Point
# → Camera fokussiert Caprica
# → Musik spielt weiter
```

---

## 📊 Mercury Phase Summary

| Mission | Fokus | Wie lange? | DoD |
|---------|-------|-----------|-----|
| **0** | Sprite Animation Pipeline | 1-2 Tage | Caprica Idle/Walk/Jump |
| **1** | Beat Detection | 2-3 Tage | Beat-Signal zuverlässig |
| **2** | Intent System | 1-2 Tage | Input → Intent funktioniert |
| **3** | First Enemy | 2-3 Tage | Zombie spawnt & stirbt |
| **4** | Attack & Combo | 3-4 Tage | Kick registriert, Beat-Bonus |
| **5** | Boss & Waves | 3-4 Tage | Boss-Encounter mit Musik |
| **6** | Level Navigation | 2-3 Tage | Portal funktioniert |
| **TOTAL** | **Mercury Phase** | **~2-3 Wochen** | **Spielbare 1-Level-Demo** |

---

## 🎮 Nach Mercury: Spielbar?

Nach Mercury 0-6 hast du:

✅ Caprica kann laufen, springen, doppeljumpen
✅ Erste Attack (Kick) funktioniert
✅ Erster Gegner (Zombie) spawnt & stirbt
✅ Beat-Detektion funktioniert
✅ Beat-Timing Bonus gibt Extra-Schaden
✅ Boss-Encounter mit Music-Waves
✅ Level-Wechsel funktioniert

**Das ist kein komplettes Spiel, aber es ist ein funktionierendes System-Demo.**

---

## ⚠️ Wichtig: Mercury ist Isolation

Jede Mercury-Mission macht **EINE Sache und macht sie gut.**

❌ **NICHT:**

- "Lass mich Combo-System, Visual-Effects, Sound-Effects und Difficulty-Balancing gleichzeitig machen"
- "Ich mache schnell die Animation fertig und springe zu Combat"
- "Lass mich jetzt schon die Home Studio implementieren"

✅ **JA:**

- Mercury 0: Animation. Fertig. Gut.
- Mercury 1: Beats. Fertig. Gut.
- Mercury 2: Input. Fertig. Gut.
- etc.

**One System at a Time.**

---

## 🔜 Was Kommt Nach Mercury?

**Das ist NICHT JETZT relevant!** Aber zur Info:

🟢 **Gemini Phase** (nach Mercury)

- Multiple Enemy-Types
- Home Studio UI
- Audio-System Refinement
- Deliverable: 3-Level Campaign

🟡 **Apollo Phase** (nach Gemini)

- Story Integration
- Visual Polish
- Boss Variety
- Deliverable: Vertical Slice

🔴 **Artemis Phase** (parallel Apollo)

- Advanced Sample-Mixing
- Community Features
- Deliverable: Creative Experience

**Aber das ist später.** Fokus jetzt: Mercury.

---

## 💡 Dein Fokus JETZT

1. Starte mit Mercury 0 (Animation)
2. Mach es fertig
3. Mach Mercury 1 (Beat Detection)
4. Mach es fertig
5. ... weiter
6. Nach Mercury 6: Spielbar!

**One at a time. One system at a time.**

---

**Version:** 1.0
**Status:** Mercury Phase Active
**Zuletzt aktualisiert:** 30. Dezember 2025
