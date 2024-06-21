extends MeshInstance3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scale -= delta*Vector3(0.8, 0.8, 0.8)
	if scale.y < 0:
		queue_free()
