extends Node

var VELOCITY : float
var parent

func initialize(speed, start): #spawn objecten op 14 x
	parent = get_parent()
	parent.position = start
	VELOCITY = speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	parent.position.x += delta*VELOCITY
	if abs(parent.position.x)>5+parent.scale.x/2:
		parent.position.x += delta*VELOCITY*2
	if abs(parent.position.x) > 15:
		queue_free()
