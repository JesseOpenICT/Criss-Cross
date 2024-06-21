extends Node3D

var rng = RandomNumberGenerator.new()
var HURTBOX
var PIERCE :bool = false
var LAUNCHTIME:float = 0

# Called when the node enters the scene tree for the first time.
func initialize(a, b):
	HURTBOX = $Hurtbox
	$Motion.initialize(a, b)
	$vehicles.setbody()
	global_rotation = get_parent().rotation

func instantiate():
	pass

func hit(move, direction):
	if HURTBOX.is_in_group("Vulnerable"):
		if move=="K":
			destroy()
		elif move=="T":
			HURTBOX.add_to_group("Airborne")
			HURTBOX.remove_from_group("Lethal")
			HURTBOX.remove_from_group("Vulnerable")
			$Recovery.stop()
			$Recovery.start()

	elif HURTBOX.is_in_group("Spinning"):
		if move=="P" or move=="T":
			launch(direction)

	elif HURTBOX.is_in_group("Airborne"):
		launch(direction, true)
	
	elif HURTBOX.is_in_group("Lethal"):
		if move=="P" or move=="T":
			HURTBOX.add_to_group("Vulnerable")
			$Recovery.stop()
			$Recovery.start()
		if move=="K":
			HURTBOX.add_to_group("Spinning")
			$Recovery.stop()
			$Recovery.start()

func _process(delta):
	if HURTBOX.is_in_group("Airborne"):
		position = position.move_toward(Vector3(position.x,3,position.z), delta*40)
	else:
		position = position.move_toward(Vector3(position.x,1,position.z), delta*40)
	if HURTBOX.is_in_group("Spinning"):
		rotation.x += 8 * delta
	else: 
		rotation.x = 0
	if HURTBOX.is_in_group("Projectile"):
		$vehicles.BODY.get_surface_override_material(0).emission = Color(1,0.4,0)
		position += Vector3(20,0,0).rotated(Vector3(0,1,0), global_rotation.y) * delta
		LAUNCHTIME += delta
		if LAUNCHTIME > 5:
			queue_free()
	elif HURTBOX.is_in_group("Vulnerable"):
		$vehicles.BODY.get_surface_override_material(0).emission = Color(0.48,0,0.92)
	else:
		$vehicles.BODY.get_surface_override_material(0).emission = Color(0,0,0)

func _on_recovery_timeout():
	$Recovery.stop()
	for group in ["Vulnerable", "Spinning", "Airborne"]:
		HURTBOX.remove_from_group(group)
	await get_tree().create_timer(0.4).timeout
	HURTBOX.add_to_group("Lethal")

func launch(direction, power=false):
	$Recovery.stop()
	for group in ["Vulnerable", "Spinning", "Airborne", "Lethal"]:
		HURTBOX.remove_from_group(group)
	HURTBOX.add_to_group("Projectile")
	rotation.y=direction+PI/2
	print(str(rotation.y)+". "+str(direction+PI/2)+". ")
	$Motion.queue_free()
	PIERCE = power

func _on_hurtbox_area_entered(area):
	if area.is_in_group("Jumping"):
		destroy()
	if area.is_in_group("Lethal") and HURTBOX.is_in_group("Projectile"):
		if not PIERCE:
			destroy()
		area.get_parent().destroy()

func destroy():
	get_parent().get_parent().blast(HURTBOX.global_position)
	get_parent().get_parent().OBJECTS_BROKEN += 1
	queue_free()
