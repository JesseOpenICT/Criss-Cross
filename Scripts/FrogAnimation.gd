extends Node3D


func animate(animation):
	$AnimationPlayer.play("Idle")
	$AnimationPlayer.play(animation)
	
func _process(delta):
	var particle = preload("res://Scenes/particle.tscn").instantiate()
	add_child(particle)
	particle.position = $Armature/Skeleton3D/Icosphere.position
	particle.scale = $Armature/Skeleton3D/Icosphere.scale*.2
