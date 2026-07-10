# Animation Pipeline

Dieses Dokument beschreibt die aktuelle Animationsentscheidung für CapricaGame.

## Entscheidung

CapricaGame verwendet keine Paperdoll-Animation als aktive Zielarchitektur mehr. Die aktuelle Richtung ist eine Sprite-basierte Pipeline mit PixelLab-AI-generierten Animationen und Godot `AnimatedSprite2D` beziehungsweise Sprite-Sheets.

## Warum

Paperdoll mit Bone2D und Skeleton2D war als wiederverwendbares Rig attraktiv, erzeugt aber für den aktuellen Projektstand zu viel technischen Vorlauf. PixelLab AI erlaubt schneller sichtbare Caprica-, Gegner- und Combat-Animationen. Für die Mercury-Demo ist das wichtiger als ein flexibles Rig-System.

## Aktive Pipeline

1. Character- oder Enemy-Animation in PixelLab AI generieren.
2. Frames oder Sprite-Sheets in `res/Assets/Characters/` beziehungsweise `res/Assets/Sprites/` ablegen.
3. Animationen in Godot über `AnimatedSprite2D` oder SpriteFrames integrieren.
4. Animationsnamen zentral über `res/Globals/ANIMATIONS.gd` beziehungsweise die aktive Player-Szene konsistent halten.
5. States spielen nur benannte Animationen ab und enthalten keine Asset-spezifische Logik.

## Aktive technische Wahrheit

Der aktuelle Player verwendet `res://Scenes/player.tscn` mit einem `AnimatedSprite2D`-basierten Sprite und State-Skripten unter `res://Scripts/`.

## Umgang mit alten Paperdoll-Dokumenten

Paperdoll-Dokumente bleiben als Archiv erhalten, sind aber nicht mehr die aktive Roadmap. Wenn ein altes Dokument Paperdoll als nächsten Schritt beschreibt, gilt diese Datei hier als neuere Entscheidung.

## Nächste Schritte

1. Aktive Caprica-Animationen inventarisieren.
2. Animationsnamen zwischen SpriteFrames, States und `ANIMATIONS.gd` abgleichen.
3. PixelLab-Exportkonvention festlegen: Frame-Größe, Richtung, Dateinamen, FPS.
4. Alte Paperdoll-Missionsziele in der aktiven Roadmap auf Sprite-Integration umstellen.
