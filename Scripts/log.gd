extends MeshInstance3D

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func initialize(a, b):
	$Motion.initialize(a, b)
	scale.x = rng.randi_range(1, 3)

func instantiate():
	pass

func _on_timer_timeout():
	for i in [$Spawn]:
		var particle = preload("res://Scenes/particle.tscn").instantiate()
		get_parent().get_parent().add_child(particle)
		particle.global_position = i.global_position
		particle.scale = Vector3(1,1,1) * 0.3
	$Timer.wait_time = randf_range(0.4,2)
	$Timer.start()
