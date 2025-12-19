extends Node
class_name Puppeteer

## Basis-Interface für alle Objekte, die einen Player kontrollieren können
## Stühle, Dosen, Fahrstühle, etc. erben davon

## Wird aufgerufen, wenn Player captured wird
func on_capture(player: Player):
	pass

## Wird aufgerufen, wenn Player ein Intent emittiert (während controlled)
func on_intent(intent: Intent):
	pass

## Wird aufgerufen, wenn Player released wird
func on_release(player: Player):
	pass
