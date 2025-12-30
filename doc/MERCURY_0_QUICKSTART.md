# Mercury 0 - Quick Start: Von Warrior zu Caprica

**Heute starten wir den Switch!** 🎸

Du wechselst von Default Asset Store Warrior zu **Caprica Game Avatar mit eigenem Paperdoll-Rig**.

---

## 🚀 Was passiert heute

1. **Assets sammeln** → Caprica Body-Parts
2. **Bone2D Scene aufbauen** → Skeleton + Bones
3. **Animancer Script schreiben** → Idle/Walk/Jump
4. **Integrieren** → Player nutzt Caprica
5. **Testen** → Animations funktionieren

**Zeit:** ~4-6 Stunden (für einen Entwickler)

---

## 📋 Step-by-Step

### Phase 1: Assets (1-2 Stunden)

**Option A: Aus Concept Art verwenden**
```
doc/Concept Art/
├── Caprica Character Concept Art.png  ← Nutzen als Reference
├── Pixelart Caprica At Home.png
├── etc.
```

**Option B: KI-generieren (schnell)**
- Prompt an DALL-E/Midjourney: "Caprica rockstar character sprite sheet 64x64, separate body parts"
- Output: Individual PNGs (Head, Arms, Legs, Torso)

**Option C: Schnell Placeholder (zum Testen)**
```
res/Assets/Characters/Paperdolls/Caprica/
├── Head.png           (64x64, rote Rechteck mit weißer Outline)
├── Torso.png          (64x64, orange Rechteck)
├── ArmUpper_L.png     (32x64, gelbe Rechteck)
├── ... (weitere)
```

→ Später: Richtige Grafiken einfach ersetzen!

**Ziel:** Alle 15 Body-Parts als PNG in `res/Assets/Characters/Paperdolls/Caprica/`

---

### Phase 2: Godot Scene Setup (1-2 Stunden)

**Im Godot Editor:**

1. **Neue Scene erstellen**
   - Root: Node2D (benenne "Caprica")
   - Speichern: `res/Scenes/caprica_paperdoll.tscn`

2. **Child: Skeleton2D hinzufügen**
   - Im Skeleton2D: Bone2D (Root) erstellen
   - Hierarchie aufbauen (siehe [MERCURY_0_IMPLEMENTATION.md](MERCURY_0_IMPLEMENTATION.md))

3. **Für jedes Bone: Sprite2D hinzufügen**
   - Head Bone → Sprite2D mit Head.png
   - Torso Bone → Sprite2D mit Torso.png
   - etc.

4. **Pivot-Points anpassen**
   - Sprite Offset = Gelenk-Position
   - z.B. Hand: Offset sollte auf Handgelenk zeigen

**Quick-Check:** Bones sollten im Editor sichtbar sein (blaue Linien)

---

### Phase 3: Script schreiben (1-2 Stunden)

**Erstelle:** `res/Scripts/caprica_animancer.gd`

Code-Template ist in [MERCURY_0_IMPLEMENTATION.md](MERCURY_0_IMPLEMENTATION.md)!

Kopiere einfach und paste in deinen Script-Editor.

---

### Phase 4: Integration (30-60 min)

**Option A: Player scene updaten**
- Alt-Warrior-Content aus `res/Scenes/player.tscn` entfernen
- `caprica_paperdoll.tscn` als Instance hinzufügen

**Option B: Neue Scene erstellen (sicherer)**
- `res/Scenes/caprica_player.tscn` neu
- Alte `player.tscn` als Fallback

---

### Phase 5: Test (30-60 min)

**Erstelle:** `res/Scripts/test_mercury_0.gd`

```gdscript
extends Node

@onready var caprica = $CapricaPlayer/Caprica  # Adjust path!

func _ready():
	print("Mercury 0 Test Started")
	caprica.play_animation("idle")

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_I:
				print("Idle")
				caprica.play_animation("idle")
			KEY_W:
				print("Walk")
				caprica.play_animation("walk")
			KEY_J:
				print("Jump")
				caprica.play_animation("jump")
```

**Test:**
- Press I → Idle (Caprica steht)
- Press W → Walk (Caprica läuft)
- Press J → Jump (Caprica springt)

✅ **Wenn das funktioniert: Mercury 0 DONE!**

---

## ⚠️ Häufige Probleme & Lösungen

| Problem | Ursache | Lösung |
|---------|--------|--------|
| Bones sichtbar aber Sprites nicht | Sprite Offsets falsch | Offset für Sprite einstellen (Gelenk-Position) |
| Bones bewegen sich nicht | Keine Animation läuft | `play_animation()` aufrufen (nur nach `_ready()`) |
| Sprite "floating" | Pivot-Point falsch | Sprite Offset = -Bone-Position |
| Animation sieht "steif" | Zu wenige Keyframes | Mehr Zwischenwerte in Curves hinzufügen |
| Bones in falscher Position | Bone-Hierarchie falsch | Check: Torso ist Parent von Arm, nicht Root |

---

## 🎯 Success Criteria für Mercury 0

✅ Caprica ist im Spiel (nicht Warrior)
✅ Idle-Animation funktioniert (Caprica steht und "atmet")
✅ Walk-Animation funktioniert (Caprica läuft vorwärts/rückwärts)
✅ Jump-Animation funktioniert (Caprica springt)
✅ Zombie kann mit gleichem Rig testen (Reusability!)
✅ Code ist clean und dokumentiert

---

## 📚 Dokumentation

- [MERCURY_0_IMPLEMENTATION.md](MERCURY_0_IMPLEMENTATION.md) ← Detaillierter Implementation-Guide
- [PAPERDOLL_ANIMATION.md](PAPERDOLL_ANIMATION.md) ← Theorie & Best Practices
- [MERCURY_PHASE.md](MERCURY_PHASE.md) ← Überblick aller Mercury-Missionen

---

## 🚀 Nach Mercury 0?

Sobald Mercury 0 DONE ist:

1. Gib dir selbst 5 Minuten Celebration 🎸
2. Starte Mercury 1 (Beat Detection)
3. Nutze Caprica weiterhin (Animation ist fix!)

**Nächster Meilenstein:** Beat-System funktioniert mit Musik!

---

## 💬 Pro-Tips

- **Bones debuggen:** Im Godot Editor "Skeleton" → "Show Bones" aktivieren
- **Animations schnell testen:** Script-Changes = sofort im Play-Mode sichtbar
- **Pivot-Points:** Geogebra oder Paint nutzen um Offset zu visualisieren
- **Versionskontrolle:** Commit nach Phase abschließen ("Mercury 0: Caprica Avatar")

---

**Status:** Ready to START
**Ziel:** Spielbar mit Caprica statt Warrior
**Ergebnis:** Aus Tutorial wird dein eigenes Game!

🎵 **"Caprica kämpft zu ihrer Musik"** – und jetzt kann sie auch LAUFEN! 🎸

---

**Erstellt:** 30. Dezember 2025
**Für:** Jérôme
