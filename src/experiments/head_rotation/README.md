# Parallax Occlusion Mapping für 2D Head Rotation

## Was ist das?

**Parallax Occlusion Mapping (POM)** verschiebt Pixel basierend auf einer **Normal Map** um 3D-Tiefe zu simulieren. Das ermöglicht subtile Rotationen ohne echte 3D-Geometrie!

## Wie funktioniert's?

```
Front Sprite + Normal Map → Shader verschiebt Pixel → Pseudo-3D Rotation
```

### Ray-Marching Algorithmus:
1. **View Direction** = Rotationswinkel (links/rechts)
2. **Height Map** (Alpha-Kanal der Normal Map) = Tiefe jedes Pixels
3. **Ray-Marching**: Shader "schießt" Strahlen durch Height Field
4. **UV-Offset**: Pixel werden horizontal verschoben basierend auf Tiefe
5. **Side Blending**: Bei extremen Winkeln wird zu Left/Right Sprite übergeblendet

## Setup:

### 1. Textures vorbereiten:
- **Center Sprite**: Front-Ansicht von Caprica
- **Left/Right Sprites**: Seitenansichten (optional, für extreme Winkel)
- **Normal Map**: RGB = Normalen, **Alpha = Height/Depth** (wichtig!)

### 2. Normal Map erstellen:

#### Option A: Photoshop/GIMP
1. Filter → 3D → Generate Normal Map
2. **Wichtig**: Exportiere mit **Alpha-Kanal als Height Map**

#### Option B: Online Tools
- [NormalMap-Online](https://cpetry.github.io/NormalMap-Online/)
- [Sprite Illuminator](https://www.codeandweb.com/spriteilluminator)

#### Option C: Manuell malen
- Weiß = nah zur Kamera (Nase, Stirn)
- Schwarz = weit weg (Seiten des Kopfes)
- Grau = mittel

### 3. In Godot einbinden:

```gdscript
# Im Inspector des CapricaHead Nodes:
texture_center = preload("res://Assets/caprica_front.png")
texture_left = preload("res://Assets/caprica_left.png")
texture_right = preload("res://Assets/caprica_right.png")
normal_map = preload("res://Assets/caprica_front_normal.png")
```

## Parameter:

### `rotation_angle` (-1.0 bis 1.0)
- `-1.0` = Volle Rotation nach links
- `0.0` = Frontal
- `1.0` = Volle Rotation nach rechts

### `parallax_strength` (0.0 bis 0.1)
- Wie stark werden Pixel verschoben?
- Start: `0.02` (subtil)
- Höher = extremerer Effekt

### `parallax_samples` (4 bis 32)
- Qualität des Ray-Marching
- Mehr Samples = bessere Qualität, aber langsamer
- Start: `16`

### `side_blend_threshold` (0.3 bis 0.9)
- Ab welchem Winkel zu Side-View wechseln?
- `0.6` = Wechsel bei 60% Rotation

## Testen:

1. Öffne `src/experiments/head_rotation/head_rotation_parallax_test.tscn`
2. Weise Textures + Normal Map zu
3. Play Scene (F6)
4. Spiele mit den Slidern!

## Tipps:

### Für beste Ergebnisse:
- Normal Map sollte **subtile** Tiefenunterschiede haben
- Pixel Art: Nutze `filter_nearest` in Shader (bereits eingestellt)
- Bei zu starkem Effekt: `parallax_strength` reduzieren
- Bei Artefakten: `parallax_samples` erhöhen

### Limitierungen:
- Funktioniert am besten für **kleine Rotationen** (±30°)
- Bei extremen Winkeln besser echte Side-Sprites nutzen
- Occlusion (Verdeckung) ist nicht perfekt

## Alternative: Simpler Ansatz

Falls POM zu komplex ist, nutze die **Frame-Switching Variante**:
- `src/experiments/head_rotation/head_rotation_test.tscn`
- Einfacher, aber keine echte Pixel-Verschiebung
