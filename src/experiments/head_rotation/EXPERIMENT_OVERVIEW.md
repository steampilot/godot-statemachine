# Head Rotation Experiment (SRC)

**Status:** Experiment / Future Feature  
**Priorität:** Low (Advanced Feature für Mercury-3+)  
**Verschoben aus RES am:** 01.01.2026

---

## Warum ist das hier?

Head Rotation mit **Parallax Occlusion Mapping** und **Shader-basierten Blends** ist ein **fortgeschrittenes Konzept**, das weiterführendes Wissen erfordert:

- ❌ Nicht für MVP (Mercury-1/2) notwendig
- ❌ Erfordert Custom Shader-Kenntnisse
- ❌ Komplex zu debuggen
- ✅ Cool für später (Mercury-3+)
- ✅ Demonstriert technisches Potenzial

**Entscheidung:** Bleibt als Referenz in **SRC**, bis wir bereit sind, es zu integrieren.

---

## Was ist in diesem Experiment?

### 1. Shader-Basierte Head Rotation
**Files:**
- `head_rotation_45degree.gdshader`
- `head_rotation_blend.gdshader`

**Konzept:**  
Nutze GPU Shader, um zwischen 3 Head-Frames (Left/Center/Right) zu blenden, basierend auf View-Angle.

**Vorteil:**
- Smooth rotation ohne viele Frames
- GPU-beschleunigt

**Nachteil:**
- Custom Shader Code (nicht trivial)
- Debugging schwierig

---

### 2. Test Scenes
**Files:**
- `head_rotation_test.tscn`
- `head_rotation_45degree_test.tscn`
- `head_rotation_parallax_test.tscn`

**Zweck:**  
Isolierte Test-Umgebungen, um Shader-Effekte zu sehen (ohne Game-Logic).

**UI Features:**
- Slider für manuelle Rotation (Debug)
- Label für aktuelle Angle
- Echtzeit-Vorschau

---

### 3. Scripts
**Files:**
- `head_rotation_test.gd`
- `head_rotation_45degree.gd`
- `head_rotation_parallax.gd`

**Funktion:**
- Laden von Head-Frames (Left/Center/Right)
- Shader-Parameter setzen (rotation_angle, blend_factor)
- Input-Handling (Slider)

---

### 4. Dokumentation
**File:** `README.md` (ehemals `PARALLAX_HEAD_ROTATION.md`)

**Inhalt:**
- Erklärung von Parallax Occlusion Mapping
- Shader Code Breakdown
- How-To für Integration

---

## Assets (bleiben in RES/Assets/Graphics/Test)

**Caprica Head Frames:**
- `caprica_head_center.svg`
- `caprica_head_left.svg`
- `caprica_head_right.svg`
- `caprica_head_center_left.svg` (Blending-Frame)
- `caprica_head_center_right.svg` (Blending-Frame)

**Warum bleiben sie in RES?**  
Assets sind Teil der Test-Suite und können auch für andere Zwecke genutzt werden (z.B. UI-Icons).

---

## Wann wird das integriert?

### Nicht vor Mercury-3

**Voraussetzungen für Integration:**
1. ✅ Caprica Paperdoll Avatar funktioniert (Mercury-1)
2. ✅ RockJay System funktioniert (Mercury-2)
3. ✅ Grundlegende Animationen funktionieren (Idle, Walk, Jump)
4. ❌ Team hat Shader-Kenntnisse
5. ❌ Performance-Budget erlaubt Custom Shader

### Mögliche Integration (Mercury-3+)

**Scenario:** Caprica schaut in Richtung des Cursors (Aim-Mechanic).

**Workflow:**
1. Get Mouse Position (World Space)
2. Calculate Angle zwischen Caprica und Cursor
3. Normalize Angle (-45° bis +45°)
4. Pass Angle an Shader
5. Shader blendet zwischen Left/Center/Right Frames

**Alternative (einfacher):**  
Nutze 3-5 diskrete Sprite-Frames statt Shader-Blending (klassischer Ansatz).

---

## How to Test (Falls du es ausprobieren willst)

### Schritt 1: Scene öffnen
```
Godot Editor → Öffne src/experiments/head_rotation/head_rotation_parallax_test.tscn
```

### Schritt 2: Play Scene
- Drücke F6 (Play Current Scene)

### Schritt 3: Slider bewegen
- Bewege Slider von -45° bis +45°
- Beobachte: Head rotiert smooth zwischen Frames

### Schritt 4: Code anschauen
- Öffne `head_rotation_parallax.gd`
- Studiere `set_head_rotation()` Funktion
- Öffne `head_rotation_blend.gdshader`
- Studiere Shader-Code

---

## Referenzen

### Shader Basics
- [Godot Shader Reference](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/index.html)
- [2D Shader Tutorial](https://docs.godotengine.org/en/stable/tutorials/shaders/your_first_shader/your_first_2d_shader.html)

### Parallax Occlusion Mapping
- [Wikipedia: Parallax Mapping](https://en.wikipedia.org/wiki/Parallax_mapping)
- [GPU Gems 3: POM](https://developer.nvidia.com/gpugems/GPUGems3/gpugems3_ch08.html)

### Similar Games with Head Rotation
- **Cuphead:** Frame-based rotation (5-7 frames)
- **Hollow Knight:** 3-frame rotation (Left/Center/Right)
- **Dead Cells:** Shader-basierte rotation (ähnlich wie unser Experiment)

---

## Next Steps (wenn Integration geplant ist)

1. **Performance-Test:** Shader auf Target-Hardware testen
2. **Art Direction:** Entscheiden, ob Shader-Look passt
3. **Refactor:** Shader in wiederverwendbare Komponente umbauen
4. **Integration:** In CapricaAvatar Paperdoll integrieren
5. **Polish:** Easing Curves, Fallback für Low-End Hardware

---

## Anmerkungen

- **Shader Code ist experimental** (nicht production-ready)
- **Keine Error-Handling** (Shader crasht bei falschen Inputs)
- **Keine Fallback** (falls Shader nicht supported)
- **Keine Tests** (nur manuelle Tests via Scene)

**TODO:** Refactoring nötig, bevor Integration!

---

**Ende Experiment Overview**
