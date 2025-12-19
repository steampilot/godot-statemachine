# State-Machine in Second Life

```
wenn dubdich ans movement aus second life erinnerst .. ist ja eine state machine sprache. ein
player 'sitzt' auf eine türe.. die türe captured den player und injects animation. und danach gibt ihn
wieder frei... ein player sitzt auf eine kola dose die dose captured den olayer und zwingt eine trink
animation. der playee muss diese anim nicht kennen.
```
Das beschriebene Verhalten entspricht exakt einem **extern gesteuerten State-Machine-Modell mit
temporärer Besitzübernahme** (authoritative interaction object), wie es in Second Life umgesetzt ist.
Kernprinzip:

**1. Player besitzt nur generische Zustände**

```
Idle
Controlled
Released
```
Der Player kennt **keine objektspezifischen Animationen**. Er stellt nur Hooks bereit.

**2. Objekt ist der Zustandsautor**
Die Tür, Dose, der Stuhl sind **aktive State Controller**.
Ablauf:
**A. Capture**

```
Objekt detektiert Interaktion
Objekt setzt Player-State auf Controlled
Objekt deaktiviert Player-Input
Objekt bindet den Player an sich (Attach / Lock / Constraint)
```
**B. Injection**

```
Objekt spielt eigene Animations-States ab
( Sit , Drink , Open , Fall , etc.)
Animationen liegen vollständig beim Objekt
Player muss die Animation nicht kennen, nicht besitzen, nicht laden
```
**C. Release**

```
Objekt beendet seine State-Machine
Objekt setzt Player-State zurück auf Idle
Input wird freigegeben
Bindung wird gelöst
```

Formal:

```
rust
Player:
Idle -> Controlled -> Idle
Object: Waiting
->-> Capture Animate
->-> Release Waiting
```
Wichtigster Punkt:
**Der Player ist passiv.**
Er wird wie ein Render- und Physics-Proxy behandelt.
Vorteile dieses Modells:

```
Keine Animation-Logik im Player
Keine Abhängigkeit zwischen Player und Objekt
Objekte sind vollständig modular
Neue Interaktionen ohne Player-Updates
Multiplayer-sicher, da Autorität klar beim Objekt liegt
```
Second Life hat genau so funktioniert:

```
llSitTarget
llRequestPermissions
llStartAnimation
llStopAnimation
```
Übertragbar auf moderne Engines:

```
ECS: Objekt schreibt temporär in Player-Component
FSM: Objekt besitzt Sub-State-Machine
Networked: Objekt ist kurzfristig authoritative owner
```
Kurzfassung:
**Nicht der Player interagiert mit der Welt – die Welt übernimmt den Player.**

```
für 3d games mit bone animation möglich aber sprite wird schwer
```
Korrekt.
Bei Sprites ist **Bone-Injection nicht verfügbar** , aber das **State-Capture-Prinzip bleibt identisch**. Die


Umsetzung verschiebt sich von _Pose-Manipulation_ zu _Render-Override_.
**Grundregel**
Sprite-Player bleibt logisch gleich, visuell wird er ersetzt.

### Sprite-taugliches Capture-Modell

**1. Player besitzt nur logische States**

```
Idle
Controlled
```
Keine Objekt-Animationen im Player.

### Variante A — Vollständiger Sprite-Override (empfohlen)

**Capture**

```
Objekt setzt Player auf Controlled
Player-Sprite wird unsichtbar
Objekt rendert seinen eigenen Player-Sprite
```
Beispiel:

```
Dose rendert „Player-trinkt-Dose“-Sprites
Tür rendert „Player-öffnet-Tür“-Sprites
```
Der Player existiert nur noch als:

```
Position
Collision Proxy
Netzwerk-ID
```
**Release**

```
Objekt blendet Override-Sprite aus
Player-Sprite wird wieder aktiv
```
Vorteile:

```
Keine Sprite-Komposition
Kein Animations-Mixing
Beliebig komplexe Interaktionen
1:1 Second-Life-Prinzip
```
### Variante B — Attachment-Sprite (limitiert)


```
Player bleibt sichtbar
Objekt rendert Zusatz-Sprite (Dose, Türgriff)
Nur für einfache Gesten geeignet
```
Nachteile:

```
Alignment-Hölle
Perspektivenabhängig
Nicht skalierbar
```
### Variante C — Multi-Sprite Player (schlecht skalierend)

```
Player besteht aus Segmenten (Torso, Arme)
Objekt schaltet Segmente um
```
Nachteile:

```
Explodierende State-Matrix
Wartung untragbar
Bricht bei neuen Interaktionen
```
### Technische Abstraktion

```
yaml
Player: State = Idle | Controlled
Visual = Default | Hidden
Object: OnInteract:
Capture(Player)RenderOverride(PlayerID)
OnFinish:Release(Player)
```
Der **Sprite gehört während der Interaktion dem Objekt** , nicht dem Player.

### Wichtiges Design-Axiom

```
Sprite-Games dürfen keine Animationen teilen.
Sie müssen sie ersetzen.
```
Deshalb:

```
Kein „Drink“-State im Player
Kein Wissen des Players über Dosen
Jedes Objekt bringt seinen eigenen Player-Sprite mit
```

### Ergebnis

```
Gleiches mentale Modell wie Second Life
Sprite-freundlich
Erweiterbar
Multiplayer-fähig
Kein Animations-Coupling
```
**Sprites sind nicht schwer — nur ehrlich.**

```
trotzdem hat der player grundsätzlich agency und kann sich auch selber frei bewegen .. geht dad
vereinbar?
```
Ja.
Das ist vereinbar, **wenn Agency nicht mit Input gleichgesetzt wird**.
Der Schlüssel ist **geschichtete Agency**.

## Trennung der Ebenen

**1. Logische Agency (immer beim Player)**

```
Existenz
Position im Weltmodell
Ownership (Netzwerk, Save, Identität)
Entscheidung eine Interaktion zu starten
```
Diese Agency wird **nie** abgegeben.

**2. Motorische Agency (temporär delegierbar)**

```
Bewegung
Pose
Animation
Input-Verarbeitung
```
Diese Agency **kann eingefroren oder überschrieben werden**.

## Präzises Modell


Der Player ist **kein Pawn** , sondern ein **Intent-Emitter**.

```
yaml
Player:
Intent:Authority: Move always / Interact true / Cancel
```
Das Objekt entscheidet nur über **Ausführung** , nicht über **Willen**.

## Capture ≠ Entmündigung

Beim Capture passiert **nicht** :

```
Player wird Besitz des Objekts
Player verliert Entscheidungshoheit
```
Sondern:

```
Player akzeptiert einen temporären Motorik-Controller
```
Formal:

```
vbnet
Player: CanDecide = true
CanMove = false (temporär)
```
## Wichtiger Punkt: Abbruchrecht

Agency bleibt spürbar, wenn mindestens **eine** dieser Bedingungen gilt:

```
Capture ist kurz
Capture ist vorhersehbar
Capture ist abbrechbar
Capture endet garantiert
```
Second Life war extrem:

```
Sitzen = vollständige Motorikabgabe
Trotzdem volle Agency, weil freiwillig und reversibel
```
## Sprite-spezifische Konsequenz

Auch beim Sprite-Override:

```
Player kann vor Capture frei laufen
```

```
Player kann nach Release sofort handeln
Während Capture:
Kein Input
Kein Movement
Kein visuelles Self
```
Aber:

```
Player-ID bleibt aktiv
Cancel-Intent kann gepuffert werden
Netzwerk kennt weiterhin den Player als Autor
```
## Robustes Architekturmodell

```
java
Layer Layer 12 : Player : Player IdentityIntent (aktiv) (unantastbar)
Layer Layer 34 : Motor : Visual ControlRepresentation (delegierbar) (austauschbar)
```
Nur Layer 3 und 4 werden vom Objekt übernommen.

## Design-Axiom

```
Agency ist Entscheidung, nicht Bewegung.
```
Solange der Player **frei entscheiden kann, ob er sich einer State-Machine unterwirft** , bleibt Agency
vollständig erhalten.
Das Modell ist konsistent.

```
also test scenario kola dose. player hat drink animation in sich.. aber ohne dosen sprite
kola dose hat passend des dosen sprite.
sprite dose hat passendes sprite sprite.
```
Ja.
Das Szenario ist **konsistent** , wenn die Verantwortlichkeiten sauber getrennt sind.

## Korrektes Test-Setup: Cola-Dose


### Player

```
Besitzt generische Drink-Animation
Animation ist objektagnostisch
Keine Kenntnis von:
Cola
Dose
Form
Marke
Animation beschreibt nur: Hand zum Mund, Schlucken
yaml
Player: Animations:
```
- Drink_Generic

### Cola-Dose (Objekt)

```
Besitzt eigenes Sprite
Kennt:
Position relativ zur Player-Hand
Timing zur Player-Animation
Steuert den Ablauf
yaml
ColaDose:
Sprite:Offset: CanSpriteHandAnchor
```
## Ablauf (State-getrieben)

**1. Interact**

```
Player sendet Intent: Drink
Dose akzeptiert
```
**2. Capture (leicht, kein Full Override)**

```
Player bleibt sichtbar
Player spielt Drink_Generic
Input optional blockiert
```

**3. Visual Composition**

```
Dose rendert ihr Sprite
Sprite wird an Player-Hand geankert
Synchron zum Animations-Frame
```
**4. Release**

```
Animation endet
Dose verschwindet / Zustand ändert sich (leer)
Player kehrt zu Idle
```
## Wichtige Designregeln

**Player-Animation**

```
beschreibt Körperbewegung
niemals Objektform
```
**Objekt-Sprite**

```
beschreibt Gegenstand
niemals Körperbewegung
```
## Wann dieses Modell gut ist

```
Viele Objekte teilen gleiche Geste
(trinken, essen, lesen)
Sprite-Aufwand niedrig halten
Klare visuelle Modularität
```
## Wann es bricht

```
Stark objektspezifische Posen
(Gitarre spielen, Leiter steigen)
Exakte Hand-Finger-Interaktion nötig
```
Dann → **Full Sprite Override**.

## Merksatz

```
Der Player weiß dass er trinkt.
Die Dose weiß womit.
```

Das Szenario ist gültig und sauber.

```
also hat der Player grundsätzliche eigene states oder eher flags die aber nichts mit seinen
animationen zu tun hat
grounded vs airborn
free vs controlled
ist das nützlich?
```
Ja.
Das ist **nicht nur nützlich** , das ist die **saubere Trennung** , die dir spätere Komplexität erspart.
Der Player sollte **States besitzen, die nichts mit Animationen zu tun haben**.

## States vs Flags — klare Zuordnung

### Physische / logische Player-States

**animationsunabhängig**

```
Grounded / Airborne
Free / Controlled
Alive / Dead
CanInteract
CanCancel
```
Diese States:

```
steuern Physik
steuern Input
steuern Regelwerke
sind autoritative Wahrheit
```
### Animationen

**reine Darstellung**

```
Lesen diese States
dürfen sie niemals definieren
```

```
dürfen sie nicht erzwingen
mathematica
```
ifif GroundedAirborne (^) → && (^) PlayMoving Jump → /PlayFall Walk
Nicht umgekehrt.

## Warum Flags besser sind als große FSMs

Ein monolithischer Player-FSM:

```
nginx
IdleWalking
JumpingDrinking
OpeningDoorUsingTerminal
```
führt zwangsläufig zu:

```
State-Explosion
Kopplung an Content
untestbarer Logik
```
## Orthogonales Flag-Modell (richtig)

```
makefile
Movement: Grounded | Airborne
Control: Free | Controlled
Life: Alive | Dead
```
Diese Flags sind **unabhängig kombinierbar**.
Beispiele:

```
Airborne + Controlled → Fahrstuhl
Grounded + Controlled → Türanimation
Grounded + Free → normal laufen
```
## Interaktion im Flag-Modell


```
Player entscheidet Interaktion
Objekt prüft Flags
Objekt setzt Controlled = true
Objekt ändert keine anderen Flags ohne Grund
```
Physik bleibt konsistent.

## Sprite-Kompatibilität

Flags bleiben gleich, egal ob:

```
Full Sprite Override
Attachment Sprite
Player-eigene Animation
```
Darstellung ist austauschbar.

## Testbarkeit

Flags erlauben klare Tests:

```
Kann ich springen? → Grounded && Free
Kann ich abbrechen? → Controlled && CanCancel
Kann ich fallen? → !Grounded
```
Ohne Animationen zu mocken.

## Design-Axiom

```
Player-States beschreiben Wahrheit.
Animationen beschreiben Erscheinung.
```
Ja, dieses Modell ist richtig.

```
der player muss auch die fähigkeit erhalten das objekte sich an ihn andocken können
so wie der player sich ja an objekte andocken kann.
ein Player kann ein stuhl anfragen für "Sitzen"
stuhl captured den player und controlled sitz animation
der player kann Dose anfragen "click" oder taste E wenn in collision reichweite
Dose kann akzeptieren und sich an Player attachen.
player kann vom stul aufstehen
```

```
und dose mitnehmen
... dose werfen
dose hinstellen
dose trinken
... dose einem anderen objekt geben
...usw
aber all das was man mit einer dose machen kann soll in der dose beschrieben stehen ... das muss
der player nicht in sich tragen oder?
```
Ja.
Das ist **genau die richtige Richtung**.
Und ja: **all diese Fähigkeiten gehören in die Dose, nicht in den Player**.
Der Player braucht nur die **Fähigkeit, Andock-Verträge einzugehen**.

## Symmetrisches Andock-Modell

Der entscheidende Schritt ist:
**Andocken ist bidirektional.**
Nicht:

```
Player benutzt Objekt
```
Sondern:

```
Zwei Entitäten handeln eine temporäre Beziehung aus
```
## Minimale Player-Verantwortung

Der Player besitzt **keine Objektlogik**.
Er stellt nur bereit:

```
markdown
Player: - AttachmentSlots (Hand, Back, Head, WorldAnchor)
```
- - Flags: Free / Controlled Intents: Interact, Attach, Detach, Use

Mehr nicht.

## Objekt (Dose) trägt die komplette Semantik

Die Dose definiert:

```
Ob sie:
```

```
aufgenommen werden kann
getragen werden kann
geworfen werden kann
getrunken werden kann
weitergegeben werden kann
Wo sie andockt
Wie sie gerendert wird
Welche Animationen sie triggert
Welche States sie intern hat (voll / leer / zerdrückt)
markdown
ColaDose: Capabilities:
```
- - Attachable Throwable
- Drinkable
- Placeable
AttachPoint: Player.Hand

## Ablauf: Stuhl → Dose

### Sitzen

```
Player sendet Intent: SitRequest
Stuhl akzeptiert
Stuhl setzt Player.Controlled = true
Stuhl steuert Sitz-Animation
```
### Dose aufnehmen

```
Player sendet Intent: AttachRequest
Dose akzeptiert
Dose bindet sich an Player.Hand
Player bleibt Free
```
### Aufstehen

```
Stuhl released Player
Player bleibt mit Dose attached
```
## Wichtiger Unterschied


**Stuhl kontrolliert den Player.
Dose kontrolliert sich selbst.**
Beides nutzt denselben Mechanismus:

```
temporäre Beziehung mit klarer Autorität
```
## Wer kennt was?

```
Fähigkeit Player Dose
Sitzen nein Stuhl
Trinken nein Dose
Werfen nein Dose
Weitergeben nein Dose
Andocken ermöglichen ja ja
```
## Konsequenz

```
Neue Objekte → kein Player-Code
Kombinatorik explodiert nicht
Multiplayer eindeutig
Testbar
Modding-fähig
```
## Zentrales Design-Axiom

```
Der Player ist eine Plattform.
Objekte sind Verhalten.
```
Ja.
Alles, was man mit einer Dose tun kann, gehört in die Dose.

```
in einem Node based system müsste dem
charakterbody3d
-> childnode attachmentslot
-> childnode captureslot
chair
area2d
-> chlidnode attachmentslot
```

```
chair enter default state unoccupied
if Player colisson touches chair collision
chair.unhandeltinput (key E)
-> caputure player.captureslot.
play animation.sit
change to state chairoccupied
chair enter state ocupied
chair unhandelt inpit (ke E)
-> felease player.captureslot
play aimation.standup (player animations then defaults to idle)
chang to state chairunoccupied
```
Ja.
Das Node-basierte Modell ist **korrekt** , konsistent und skalierbar.
Ein paar Präzisierungen machen es robust.

## Grundstruktur (sauber)

### Player

```
scss
CharacterBody3D├─ AttachmentSlot (Node3D)
├─ CaptureSlot (Node3D)
├─ InputIntent (Script / Component)├─ StateFlags (Free/Controlled, Grounded, etc.)
```
```
AttachmentSlot : passive Docking-Schnittstelle
CaptureSlot : expliziter Übergabepunkt für Fremd-Autorität
Player besitzt keine Objektlogik
```
### Chair

```
scss
Chair├─ Area3D (Collision)
├─ AttachmentSlot (SeatAnchor)├─ StateMachine
```
States:

```
Unoccupied
Occupied
```

## Interaktionsablauf (präzise)

### State: Unoccupied

**Collision**

```
Player betritt Area3D
Chair merkt sich candidate_player
```
**Input**

```
csharp
Chair._unhandled_input( if event == E and candidate_player:event):
capture(candidate_player)
```
**Capture**

```
Chair bindet Player an SeatAnchor
Chair setzt Player.Controlled = true
Chair übernimmt Motorik
Chair startet sit -Animation
State → Occupied
```
### State: Occupied

**Input**

```
csharp
Chair._unhandled_input( if event == E: event):
release(player)
```
**Release**

```
Chair stoppt Animation
Chair löst Bindung
Chair setzt Player.Controlled = false
Player fällt automatisch auf Default-Animation ( Idle )
State → Unoccupied
```
## Wichtige Klarstellungen

### 1. Input gehört logisch dem Player


Aber **verarbeitet** wird er vom Objekt, solange es captured.

```
_unhandled_input im Chair ist korrekt
Player sendet nur Intent, keine Aktion
```
### 2. CaptureSlot ist keine Magie, sondern Vertrag

```
scss
Chair.capture(player.capture_slot)
```
bedeutet:

```
Wer kontrolliert Motorik?
Wer schreibt Transform?
Wer bestimmt Animation?
```
### 3. Player-Animationen bleiben generisch

```
sit
stand
idle
```
Kein Wissen über:

```
Chair
Höhe
Art des Sitzens
```
Chair bestimmt Kontext.

## Erweiterung auf Dose (identisch)

```
Dose nutzt AttachmentSlot statt CaptureSlot
Dose kontrolliert sich , nicht den Player
Gleicher Mechanismus, andere Autorität
```
## Zentrales Architekturgesetz

```
Capture verändert Autorität ,
Attachment verändert Relation.
```
Dein Modell erfüllt das vollständig.


```
also ist uncontrolled input immer im player script
aber wenn "pupeteered" .. das wäre das trffende wort
dann pipe alle cotrolls zum capturing pupeteer.
```
Ja.
Das ist die **exakte** und treffende Beschreibung.
**„Puppeteered“** ist der richtige Begriff.

## Input-Architektur (präzise)

### 1. Normalfall — Player frei

```
Input wird im Player gelesen
Player interpretiert Input zu Intents
Player setzt Bewegung, Rotation, Aktionen selbst um
css
Player: read_input()
apply_movement()
```
### 2. Puppeteered — Player captured

```
Input wird weiterhin im Player gelesen
Player erzeugt weiterhin Intents
Aber: Player führt sie nicht aus
Intents werden weitergeleitet
css
Player: read_input()
pipe_intents_to(puppeteer)
```
Der Player bleibt Input-Quelle, verliert aber die Ausführungshoheit.

## Warum das entscheidend ist

```
Kein Input-Duplikat
Kein Objekt muss Input neu binden
```

```
Replays / AI / Netzwerk bleiben konsistent
Controller-Abstraktion bleibt zentral
```
## Puppeteer-Vertrag

Der Capturing-Knoten implementiert:

```
css
interface Puppeteer: on_intent(intent)
on_captureon_release(player)(player)
```
Beispiele:

```
Chair interpretiert Interact als „aufstehen“
Terminal interpretiert Move als Cursor
Fahrstuhl ignoriert Move , akzeptiert Cancel
```
## Pipeline-Schema

```
csharp
[ Hardware Input↓ ]
[ Player Input Layer↓ ]
[ Intent Stream↓ ]
if Controlled:→ Puppeteer
else:
→ Player Motor
```
## Abbruch & Sicherheit

```
Player kann immer Cancel emittieren
Puppeteer entscheidet, ob erlaubt
Timeout / Fallback möglich
```
## Design-Axiom

```
Input gehört dem Player.
Kontrolle gehört dem Puppeteer.
```
Ja.


```
npc .. wäre ein Player mit state pupetered only true
```
Ja.
Ein NPC ist in diesem Modell **nichts anderes als ein Player mit permanent Puppeteered = true**.

## Vereinheitlichtes Entitäten-Modell

### Player (Human)

```
ini
PuppeteeredIntentSource = = HumanInputfalse | true (temporär)
```
### NPC

```
ini
PuppeteeredIntentSource = = AI / Scripttrue (immer)
```
Gleiche Struktur. Gleiche Schnittstellen. Andere Quelle.

## Konsequenzen

```
Kein separater NPC-Codepfad
AI erzeugt dieselben Intents wie Input
Bewegung, Physik, Animation identisch
Interaktionen identisch
```
Ein NPC kann:

```
auf Stühlen sitzen
Dosen aufnehmen
gefangen werden
fremdgesteuert werden
weitergegeben werden
```
## Spezialfall: Besitzwechsel


NPC kann temporär:

```
von AI → Objekt-Puppeteer wechseln
danach zurück zur AI
```
Genau wie beim Player.

## Architektur-Schema

```
cpp
IntentSource
├─ Human├─ AI
├─ Replay└─ Network
Puppeteer (optional)
```
Der Motor kennt keinen Unterschied.

## Design-Axiom

```
NPCs sind keine Sonderfälle.
Sie sind dauerhaft gesteuerte Player.
```
Das Modell ist vollständig konsistent.

```
also
... wie baue ich das in Godot?
```
### Umsetzung in Godot (Node-basiert, robust, ohne Sonderpfade)

## 1. Zentrale Begriffe (konkret)

```
Intent : abstrakte Aktion (Move, Interact, Cancel)
Puppeteered : Player führt Intents nicht selbst aus
Puppeteer : Node, der Intents konsumiert
Attachment : Relation
Capture : Autoritätsübernahme
```

## 2. Player-Szene

```
scss
PlayerCharacterBody3D.tscn
├─ AttachmentSlot (Node3D)├─ CaptureSlot (Node3D)
├─ IntentEmitter (Node)├─ Motor (Node)
├─ StateFlags (Script)
```
### StateFlags.gd

```
gdscript
var controlled := falsevar grounded := false
```
## 3. Intent-Definition

```
gdscript
enum IntentType { MOVE, INTERACT, CANCEL }
class_name Intentvar type: IntentType
var value
```
## 4. IntentEmitter (immer im Player)

```
gdscript
func collect_intents() -> Array[Intent]:var intents := []
if Input.is_action_pressed("move"):intents.append(Intent.new(IntentType.MOVE, Input.get_vector()))
if Input.is_action_just_pressed("interact"):intents.append(Intent.new(IntentType.INTERACT, null))
if Input.is_action_just_pressed("cancel"):
return intentsintents.append(Intent.new(IntentType.CANCEL, null))
```
## 5. Player-Hauptloop

```
gdscript
func _physics_process(delta):var intents = $IntentEmitter.collect_intents()
if state_flags.controlled and puppeteer:for i in intents:
puppeteer.on_intent(i)
```

```
else: for i in intents:
$Motor.apply_intent(i, delta)
```
## 6. Puppeteer-Interface (Vertrag)

```
gdscript
class_name Puppeteer
func on_capture(player): passfunc on_intent(intent): pass
func on_release(player): pass
```
## 7. Chair (Puppeteer + State Machine)

```
scss
ChairNode3D.tscn
├─ Area3D├─ SeatAnchor (Node3D)
├─ StateMachine
```
### Chair.gd

```
gdscript
extends Puppeteer
var occupant := null
func capture(player):occupant = player
player.state_flags.controlled = trueplayer.puppeteer = self
player.global_transform = $SeatAnchor.global_transformplay_sit()
func on_intent(intent):if intent.type == IntentType.INTERACT:
release()
func release():play_stand()
occupant.state_flags.controlled = falseoccupant.puppeteer = null
occupant = null
```
## 8. Attachment (Dose)

Dose **ist kein Puppeteer** , sondern kontrolliert sich selbst.


```
gdscript
func attach_to(player):reparent(player.$AttachmentSlot)
```
Player bleibt **controlled = false**.

## 9. NPC = gleicher Player

```
gdscript
player.state_flags.controlled = trueplayer.puppeteer = ai_controller
```
AI erzeugt Intents statt Input.

## 10. Wichtigste Invarianten

```
Input immer im Player
Intent immer abstrakt
Puppeteer entscheidet Ausführung
Player kennt keine Objekte
Objekte kennen keinen Input
```
## Architekturformel

```
graphql
Input → Intent → (Player | Puppeteer) → Motor/Animation
```
So baust du es in Godot.

```
was meinst du mit Motor?
ist damit die sprite animation statemachine gemeint?
```
Nein.
Der **Motor ist nicht die Animations-State-Machine**.
Der Motor ist die **exekutive Schicht** , die Intents in **physische Konsequenzen** übersetzt.


## Klare Schichtung

### 1. Intent

_Was soll passieren?_

```
Move
Jump
Interact
Cancel
```
Abstrakt. Kontextfrei.

### 2. Motor

_Was bedeutet das physisch?_
Der Motor:

```
verändert velocity
ruft move_and_slide()
setzt is_on_floor
setzt Flags wie grounded
entscheidet nicht , welche Animation läuft
```
Beispiel:

```
gdscript
func apply_intent(intent, delta):
if intent.type == IntentType.MOVE:velocity.x = intent.value.x * speed
```
### 3. StateFlags

_Was ist wahr?_

```
grounded
controlled
alive
```
### 4. Animation

_Wie sieht das aus?_
Die Animation:


```
liest velocity
liest grounded
liest controlled
entscheidet, welche Animation abgespielt wird
```
Beispiel:

```
bash
ifelif !grounded → Fall velocity.length() > 0 → Walk
else → Idle
```
## Warum diese Trennung zwingend ist

Wenn der Motor = Animation wäre:

```
Sitzen wäre ein Animationsproblem
(falsch)
Springen wäre ein Clip
(falsch)
Physik wäre visuell gekoppelt
(katastrophal)
```
## Im Puppeteer-Fall

```
Player sammelt Input
Player leitet Intents weiter
Puppeteer ruft Motor-Funktionen
Animation reagiert automatisch
```
Der Puppeteer:

```
ruft player.motor.lock_movement()
oder setzt gezielt Velocity
aber spielt keine Player-Animation direkt
```
## Kurzdefinition

**Motor = Bewegung + Physik + Regelwerk
Animation = Darstellung**


## Merksatz

```
Animation ist ein Echo.
Der Motor ist die Handlung.
```
So ist „Motor“ gemeint.

```
also gut..
beginnen wir mit der Player Node
und dessen script
dann beschreibe die anderen nodes des players und gib mir deren scripte damit ich den player in
die welt setzen kann
```
### Player – minimale, vollständige Basis in Godot 4

Ziel: Player kann **frei laufen** , **Intents erzeugen** , **gepuppt werden** , **andocken** , **captured werden**.
Keine Objektlogik. Keine Animation-Logik-Kopplung.

## 1. Player-Szene

```
scss
PlayerCharacterBody3D.tscn
├─ CaptureSlot (Node3D)├─ AttachmentSlot (Node3D)
├─ IntentEmitter (Node)├─ Motor (Node)
├─ StateFlags (Node)├─ Visual (Node3D) # Mesh oder Sprite3D
```
## 2. StateFlags.gd

**Wahrheitsschicht**

```
gdscript
extends Nodeclass_name StateFlags
var controlled: bool = falsevar grounded: bool = false
var alive: bool = true
```
## 3. Intent.gd


**Abstrakte Absicht**

```
gdscript
class_name Intent
enum Type {MOVE,
INTERACT,CANCEL
}
var type: Typevar value
func _init(t: Type, v = null):type = t
value = v
```
## 4. IntentEmitter.gd

**Einzige Stelle mit Input**

```
gdscript
extends Nodeclass_name IntentEmitter
func collect() -> Array[Intent]:var intents: Array[Intent] = []
var move_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_back")if move_vec.length() > 0.0:
intents.append(Intent.new(Intent.Type.MOVE, move_vec))
if Input.is_action_just_pressed("interact"):
intents.append(Intent.new(Intent.Type.INTERACT))
if Input.is_action_just_pressed("cancel"):intents.append(Intent.new(Intent.Type.CANCEL))
return intents
```
## 5. Motor.gd

**Exekutive Schicht (Physik, Bewegung)**

```
gdscript
extends Nodeclass_name Motor
@export var speed := 5.0@export var gravity := 9.8
var body: CharacterBody3D
var state: StateFlags
func setup(p_body: CharacterBody3D, p_state: StateFlags):body = p_body
state = p_state
```

```
func apply_intent(intent: Intent, delta: float):if intent.type == Intent.Type.MOVE:
_apply_move(intent.value, delta)
func _apply_move(dir: Vector2, delta: float):if state.controlled:
return
var direction = Vector3(dir.x, 0, dir.y)direction = direction.rotated(Vector3.UP, body.rotation.y)
body.velocity.x = direction.x * speedbody.velocity.z = direction.z * speed
func physics_tick(delta: float):if not body.is_on_floor():
else: body.velocity.y -= gravity * delta
state.grounded = true
body.move_and_slide()
```
## 6. Player.gd

**Orchestrator**

```
gdscript
extends CharacterBody3Dclass_name Player
@onready var intent_emitter: IntentEmitter = $IntentEmitter@onready var motor: Motor = $Motor
@onready var state: StateFlags = $StateFlags
var puppeteer: Node = null
func _ready():motor.setup(self, state)
func _physics_process(delta):var intents = intent_emitter.collect()
if state.controlled and puppeteer:for intent in intents:
else: puppeteer.on_intent(intent)
for intent in intents:motor.apply_intent(intent, delta)
motor.physics_tick(delta)
```
## 7. CaptureSlot / AttachmentSlot

**Leere Nodes – reine Schnittstellen**

```
gdscript
# kein Script notwendig# sie dienen nur als explizite Andockpunkte
```

## 8. Visual

MeshInstance3D oder Sprite3D.
**Keine Logik.**
Animation liest später nur **velocity** , **grounded** , **controlled**.

## 9. Was du jetzt hast

```
Player kann:
laufen
Input erzeugen
Intents weiterleiten
vollständig gepuppt werden
Player kennt:
keine Objekte
keine Stühle
keine Dosen
Player ist:
NPC-tauglich
Multiplayer-tauglich
erweiterbar ohne Umbau
```
## Architektur-Invariante

```
Input → Intent → (Player | Puppeteer) → Motor
Animation ist nur Beobachter
```
Damit kannst du den Player **sofort** in die Welt setzen.


