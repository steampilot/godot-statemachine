# SRC/Experiments - Future Features & Research

**Zweck:** Dieses Verzeichnis enthält experimentelle Features, die **zu advanced** für den aktuellen MVP-Scope sind, aber als **Referenz-Implementierungen** dienen.

---

## Was gehört hierher?

✅ **Prototypen für Future Features**
- Features, die weiterführendes Wissen erfordern
- Experimentelle Techniken (Shader, Physics, AI)
- Performance-Tests für neue Systeme

✅ **Research & Learning**
- Proof-of-Concepts
- Technologie-Demos
- Architektur-Experimente

❌ **Was NICHT hierher gehört:**
- Production-ready Code → gehört nach `res/` oder `src/components/`
- Assets → bleiben in `res/Assets/`
- Finale Dokumentation → gehört nach `doc/`

---

## Aktive Experimente

### 🔬 Head Rotation (Shader-Based)
**Path:** `head_rotation/`  
**Status:** Experiment / Low Priority  
**Verschoben am:** 01.01.2026

**Was ist das?**  
Shader-basierte Parallax Head Rotation mit GPU-beschleunigtem Blending zwischen 3-5 Head-Frames.

**Warum hier?**
- Erfordert Custom Shader-Kenntnisse
- Zu komplex für MVP (Mercury-1/2)
- Cool für später (Mercury-3+)

**Siehe:** [head_rotation/EXPERIMENT_OVERVIEW.md](head_rotation/EXPERIMENT_OVERVIEW.md)

---

## Zukünftige Experimente (Geplant)

### 🔬 Procedural Music Generation
**Idee:** Echtzeit-Generierung von Musik-Loops basierend auf Player-Actions.  
**Tech:** Godot Audio Engine + Custom Synth Nodes  
**Priorität:** Medium (Mercury-4+)

### 🔬 Dynamic Lighting System
**Idee:** 2D Shader-basierte Lighting (wie Dead Cells).  
**Tech:** Custom Fragment Shader + Normal Maps  
**Priorität:** Low (Polish Phase)

### 🔬 Procedural Level Generation
**Idee:** Rogue-Lite Level-Generation mit Music-Driven Layout.  
**Tech:** Godot TileMap + Custom Generator  
**Priorität:** Low (Post-MVP)

---

## Workflow: Experiment → Production

### Schritt 1: Experiment erstellen
- Neues Verzeichnis in `src/experiments/`
- Erstelle `EXPERIMENT_OVERVIEW.md` mit Zielen
- Implementiere Proof-of-Concept

### Schritt 2: Evaluation
- Funktioniert es?
- Performance okay?
- Passt es zum Game?

### Schritt 3: Refactoring
- Code aufräumen
- Error-Handling hinzufügen
- Tests schreiben

### Schritt 4: Migration
- Falls approved: nach `res/` oder `src/components/` verschieben
- Dokumentation nach `doc/` verschieben
- Experiment-Ordner bleibt als Archiv

---

## Regeln für Experimente

### ✅ DO:
- Kleine, fokussierte Prototypen (nicht komplettes System)
- Klare Dokumentation (EXPERIMENT_OVERVIEW.md)
- Isoliert testbar (eigene Scene/Script)

### ❌ DON'T:
- Production-Code ohne Tests
- Experimente in RES/Scenes/ mischen
- Experimente ohne Dokumentation

---

## Referenzen

- **Main Project Docs:** [doc/](../../doc/)
- **Production Code:** [res/](../../res/)
- **Component Templates:** [src/components/](../components/)

---

**Letzte Aktualisierung:** 01.01.2026
