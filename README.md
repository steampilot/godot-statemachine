# CapricaGame

CapricaGame ist ein 2D-Action-Platformer in Godot: Caprica, eine Rockstar, kämpft sich mit musikgetriebenem Movement und Combat durch AI-infizierte SLOB-Zombies nach Hause.

## Aktueller Stand

Das Repository enthält bereits spielbare Ansätze, Szenen, Sprites, Animationen und viele Designideen. Der wichtigste Punkt für die weitere Arbeit:

- `res/` ist der aktive Godot-Projektbereich. Die Hauptszene und die derzeit geladenen Spielskripte liegen hier.
- `src/` ist der Architektur- und Prototypbereich für die nächste Generation der Systeme.
- `doc/` ist das Ideen-, Design- und Architekturarchiv.
- `SCRATCH/` beziehungsweise rohe Asset-Bereiche bleiben Sammelstellen, bis Assets bewusst integriert werden.

## Einstieg

- Aktive Godot-Projektdatei: `res/project.godot`
- Main Scene: `res://Scenes/main.tscn`
- Aktiver Player: `res://Scenes/player.tscn`
- Aktive Player-Logik: `res://Scripts/player.gd`
- Streamlining-Plan: [doc/STREAMLINING.md](doc/STREAMLINING.md)
- Animationspipeline: [doc/ANIMATION_PIPELINE.md](doc/ANIMATION_PIPELINE.md)
- Master Design Guide: [doc/CAPRICA_MASTER_GUIDE.md](doc/CAPRICA_MASTER_GUIDE.md)

## Entwicklungsregel

Änderungen am spielbaren Spiel passieren zuerst in `res/`. Konzepte aus `src/` werden erst dann nach `res/` migriert, wenn sie für ein konkretes spielbares Ziel gebraucht werden.
