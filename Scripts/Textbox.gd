extends RichTextLabel

@export var IN : Vector2
@export var OUT : Vector2
var DESTINATION : Vector2 = IN

func _ready():
	DESTINATION = position

func _process(delta):
	position = position.move_toward(DESTINATION, delta*1600)

func enter(out):
	if not out:
		DESTINATION = OUT
	else:
		DESTINATION = IN
