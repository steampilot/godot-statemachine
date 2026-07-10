extends Node
class_name UTILS
## Global Singleton für Utility-Funktionen
## Verschiedenste Hilfsfunktionen

func _ready() -> void:
    set_name("UTILS")
    print("✓ UTILS Singleton initialisiert")

## Gibt Abstand zwischen zwei Positionen zurück
func distance_between(pos1: Vector2, pos2: Vector2) -> float:
    return pos1.distance_to(pos2)

## Gibt Richtung von pos1 zu pos2 zurück (normalisiert)
func direction_to(from_pos: Vector2, to_pos: Vector2) -> Vector2:
    return (to_pos - from_pos).normalized()

## Clamp Wert zwischen min und max
func clamp_value(value: float, min_val: float, max_val: float) -> float:
    return clamp(value, min_val, max_val)

## Linearer Interpolation
func lerp_val(from: float, to: float, weight: float) -> float:
    return lerp(from, to, weight)

## Konvertiert Grad zu Radianten
func deg_to_rad(degrees: float) -> float:
    return deg_to_rad(degrees)

## Konvertiert Radianten zu Grad
func rad_to_deg(radians: float) -> float:
    return rad_to_deg(radians)

## Prüft ob Punkt in Rect liegt
func point_in_rect(point: Vector2, rect: Rect2) -> bool:
    return rect.has_point(point)

## Generiert zufällige Farbe
func random_color() -> Color:
    return Color(randf(), randf(), randf())

## Gibt Array-Element oder null zurück (safe access)
func safe_array_access(arr: Array, index: int):
    if index >= 0 and index < arr.size():
        return arr[index]
    return null

## String trimmen (Whitespace entfernen)
func trim_string(s: String) -> String:
    return s.strip_edges()

## Prüft ob String leer ist
func is_empty_string(s: String) -> bool:
    return s.is_empty() or s.strip_edges().is_empty()

## Konvertiert Millisekunden zu Sekunden
func ms_to_seconds(ms: int) -> float:
    return float(ms) / 1000.0

## Konvertiert Sekunden zu Millisekunden
func seconds_to_ms(seconds: float) -> int:
    return int(seconds * 1000)
