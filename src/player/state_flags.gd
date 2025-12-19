extends Node
class_name StateFlags

## Wahrheitsschicht - Physische und logische Player-States
## Diese States sind unabhängig von Animationen

var controlled: bool = false  # Vom Puppeteer gesteuert
var grounded: bool = false    # Berührt Boden
var alive: bool = true         # Existiert noch
