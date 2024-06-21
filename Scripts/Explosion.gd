extends Node3D


# Called when the node enters the scene tree for the first time.
func instantiate():
	pass

func _ready():
	$AnimatedSprite3D.play()

func _on_animated_sprite_3d_animation_finished():
	queue_free()
