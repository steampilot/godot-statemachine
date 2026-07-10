# CapricaGame Streamlining

Dieses Dokument ist die Arbeitskarte, um das Projekt wieder in eine klare Form zu bringen, ohne funktionierende Godot-Referenzen durch vorschnelle Umzüge zu brechen.

## Ziel

CapricaGame soll wieder einen eindeutigen roten Faden haben: ein spielbarer Kern, eine klare Architektur-Richtung und ein Ideenarchiv, das inspiriert statt blockiert.

## Kanonische Bereiche

### `res/` - Aktives Spiel

`res/` ist aktuell der einzige Bereich, der direkt vom Godot-Projekt geladen wird. Hier liegen die spielbaren Szenen, Autoloads, Assets und State-Skripte.

Behandlung:

- Neue spielbare Features zuerst hier integrieren.
- Pfade nur ändern, wenn alle `.tscn`-Referenzen mitgezogen werden.
- Bestehende State-Machine nicht nebenbei ersetzen.
- Erst stabilisieren, dann modularisieren.

### `src/` - Architektur-Inkubator

`src/` enthält Komponenten, Intent-System, Game-State-Machine, Portal-Prototypen und Tests. Dieser Bereich ist wertvoll, aber derzeit nicht der aktive Godot-Laufzeitpfad.

Behandlung:

- Als Vorlage und Experimentierfläche behalten.
- Nur gezielt nach `res/` migrieren, wenn ein konkretes Mercury-Ziel es braucht.
- Keine zweite parallele Player-Implementierung produktiv pflegen.

### `doc/` - Design- und Entscheidungsarchiv

`doc/` enthält sehr viele starke Konzepte. Damit es nutzbar bleibt, braucht jedes Dokument eine Rolle.

Empfohlene Rollen:

- `CAPRICA_MASTER_GUIDE.md`: kreative Vision und Gesamtbild.
- `MERCURY_PHASE.md`: aktive Roadmap.
- `ANIMATION_PIPELINE.md`: aktive Animationsentscheidung und PixelLab-AI-Sprite-Pipeline.
- `MOVEMENT_PRIORITIES.md`: Movement-Reihenfolge.
- `COMBAT_SYSTEM.md`: Combat-Zielbild.
- `MUSIC_ATLAS_SYSTEM.md` und `SNAP_TO_BEAT_SYSTEM.md`: Musiksystem-Zielbild.
- Alle Detaildocs bleiben Archiv, bis eine Mission sie aktiv braucht.

## Aktive Design-Entscheidungen

### Animation

CapricaGame verwendet aktuell keine Paperdoll-Animation als Zielarchitektur. Die aktive Richtung ist eine Sprite-basierte Pipeline mit PixelLab-AI-generierten Animationen, Sprite-Sheets und Godot `AnimatedSprite2D`.

Alte Paperdoll-Dokumente bleiben als Archiv erhalten, gelten aber nicht mehr als aktive Roadmap.

## Aktive technische Wahrheit

Der aktuelle Laufzeitpfad ist:

```text
res/project.godot
  -> res://Scenes/main.tscn
    -> res://Scenes/level_1_1.tscn
    -> res://Scenes/player.tscn
      -> res://Scripts/player.gd
      -> res://Scripts/state_machine.gd
      -> res://Scripts/*_state.gd
```

Das bedeutet: Wenn Verhalten im Spiel geändert werden soll, beginnt die Arbeit im Normalfall bei `res/Scripts/player.gd`, `res/Scripts/state_machine.gd` oder einem konkreten State-Skript.

## Streamlining-Phasen

### Phase 1: Orientierung festziehen

Ergebnis: Jeder Einstiegspunkt sagt dasselbe über das Projekt.

- README auf CapricaGame ausrichten.
- `res/`, `src/`, `doc/` klar erklären.
- Aktive Main Scene und Player-Scene dokumentieren.
- Alte Tutorial-Namen in Projektmetadaten prüfen und gezielt ersetzen.

### Phase 2: Spielbaren Kern stabilisieren

Ergebnis: Eine kleine Demo ist jederzeit startbar.

- Player-State-Machine formatieren und vereinheitlichen.
- Movement-Basis bewusst festlegen: laufen, springen, fallen, dashen, Leiter.
- PixelLab-AI-Sprite-Pipeline als aktive Animationsbasis dokumentieren.
- Aktive Caprica-Animationen inventarisieren und Animationsnamen abgleichen.
- Health, Hurt, Death und Hitboxen auf minimale Funktion prüfen.
- Debug-Ausgaben reduzieren oder klar benennen.

### Phase 3: Architektur-Migration entscheiden

Ergebnis: Kein Doppel-System mehr ohne Zweck.

- Pro aktivem Feature entscheiden: bestehender `res`-State oder gezielte `src`-Migration.
- Komponenten nur migrieren, wenn sie sofort in einer Szene genutzt werden.
- Intent-System erst einführen, wenn der Player-Loop stabil genug ist.

### Phase 4: Content ordnen

Ergebnis: Assets und Level sind auffindbar.

- Aktive Szenen von Experiment-Szenen trennen.
- Caprica-, Gegner-, UI- und Environment-Assets gruppieren.
- Rohmaterial erst nach Sichtung in aktive Asset-Ordner verschieben.

### Phase 5: Mercury-Demo bauen

Ergebnis: Eine klare vertikale Scheibe.

- Ein Level.
- Ein Caprica-Player.
- Ein Gegner.
- Eine Attacke.
- Ein Musik-/Beat-Signal.
- Ein Portal oder Levelabschluss.

## Nächste konkrete Schritte

1. `res/project.godot` auf Projektnamen und Autoload-Duplikate prüfen.
2. Eine kleine Datei `doc/ACTIVE_SLICE.md` anlegen, die nur die aktuelle Mercury-Demo beschreibt.
3. Aktive Caprica-Sprites und Animationen gegen `res://Scenes/player.tscn` prüfen.
4. `res/Scripts/player.gd` und `res/Scripts/state_machine.gd` nach Projektkonvention ordnen.
5. Danach erst größere Ordner- oder Architekturänderungen machen.

## Arbeitsregel

Immer zuerst den aktiven Godot-Pfad schützen. Ideen werden erst dann zu Code, wenn sie ein spielbares Ziel in der aktuellen Mercury-Demo bedienen.
