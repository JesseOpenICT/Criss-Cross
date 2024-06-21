extends Node3D

signal moved
signal dead

var POSITION = Vector2(0,0)
@export var MAX_WIDTH : int = 3
@export var MIN_DISTANCE : int = 3
var DISTANCE_TRAVELED : int = 0

var ON_LOGS : int = 0
var ON_WATER : int = 0
var SIDE_VELOCITY : float 

var P_COST:float = 0.099999
var K_COST:float = 0.499999
var T_COST:float = 0.349999

var MOBILE :bool = false
var PAUSED :bool = false

var TIMER
var POWER
var HURTBOX 
var HITBOX
var SHAPE

# Called when the node enters the scene tree for the first time.
func _ready():
	HURTBOX = $Hurtbox
	HITBOX = $Hurtbox/Hitbox
	SHAPE = $Shape
	TIMER = $Timer
	POWER = $Power
	$Power.visible = false
	$Timer.visible = false
	$Markers.visible = false
	$Markers/P.position.x+=710*P_COST
	$Markers/T.position.x+=710*T_COST
	$Markers/K.position.x+=710*K_COST

func _input(event):
	if not $Ninjafrog.visible and event.is_action_pressed("Ninja Mode"):
		SHAPE.visible = false
		var particle = preload("res://Scenes/particle.tscn").instantiate()
		add_child(particle)
		particle.position = SHAPE.position
		particle.scale = 1.2*Vector3(1, 1, 1)
		SHAPE = $Ninjafrog
		SHAPE.visible = true
		$Ninja.play()
	if not PAUSED:
		if MOBILE:
			if event.is_action_pressed("Forward"):
				move(Vector2(0, 1), 3.141)
				pause()
			if event.is_action_pressed("Back"):
				move(Vector2(0, -1), 0)
				pause()
			if event.is_action_pressed("Left"):
				move(Vector2(1, 0), PI*-.5)
				pause()
			if event.is_action_pressed("Right"):
				move(Vector2(-1, 0), PI*.5)
				pause()
		
		if event.is_action_pressed("Punch") and POWER.scale.x>=P_COST:
			attack("P")
			POWER.scale.x-=P_COST
		if event.is_action_pressed("Kick") and POWER.scale.x>=K_COST:
			attack("K")
			POWER.scale.x-=K_COST
		if event.is_action_pressed("Throw") and POWER.scale.x>=T_COST:
			attack("T")
			POWER.scale.x-=T_COST
		if event.is_action_pressed("Jump") and not HURTBOX.is_in_group("Jumping"):
			jump()
	if not POWER.visible:
		POWER.scale.x = 1

func move(direction, angle):
	
	
	$Move.stop()
	$Move.play()
	
	$Power.visible = true
	$Timer.visible = true
	$Markers.visible = true
	
	POSITION.x = snapped(HURTBOX.position.x, 1)
	HURTBOX.rotation.y = angle
	if not (abs(POSITION.x + direction.x) > MAX_WIDTH) and (POSITION.y+direction.y)>=(DISTANCE_TRAVELED-MIN_DISTANCE):
		$Shape.animate("Hop")
		$Ninjafrog.animate("Hop")
		POSITION.y += direction.y
		HURTBOX.position.z += direction.y
		POSITION.x += direction.x
		HURTBOX.position.x += direction.x
		DISTANCE_TRAVELED = maxi(DISTANCE_TRAVELED, POSITION.y) #set furthest distance traveled
		
		if ON_WATER == 0:
			HURTBOX.position.x = snapped(HURTBOX.position.x, 1)
		moved.emit(DISTANCE_TRAVELED)

func attack(atk):
	if $Hurtbox.is_in_group("Jumping"):
		SHAPE.animate("Dunk")
		await get_tree().create_timer(1/6).timeout
		land()
		$JumpDuration.stop()
	elif atk=="K":
		SHAPE.animate("Kick")
	elif atk=="T":
		SHAPE.animate("Throw")
	else:
		SHAPE.animate("Punch")
	$Swipe.stream = load("res://Assets/Audio/swishes/" +atk+ ".wav")
	$Swipe.play()
	
	for target in HITBOX.get_overlapping_areas():
		for type in ["Vulnerable", "Spinning", "Airborne", "Lethal"]:
			if target.is_in_group(type):
				target.get_parent().hit(atk, HURTBOX.rotation.y)
				break


func jump():
	SHAPE.animate("Leap")
	HURTBOX.position.y = 2
	HURTBOX.add_to_group("Jumping")
	MOBILE=false
	$Hurtbox/Hitbox/CollisionShape3D.shape.size.x=2
	$JumpDuration.start()

func _on_jump_duration_timeout():
	land()
	
func land():
	HURTBOX.position.y = 0
	HURTBOX.remove_from_group("Jumping")
	MOBILE=true
	$Hurtbox/Hitbox/CollisionShape3D.shape.size.x=1

func _process(delta):
	if not $Ninjafrog.visible:
		$Ninjafrog.position = SHAPE.position
		$Ninjafrog.rotation = SHAPE.rotation
	if $Timer.visible:
		TIMER.scale.x -= 0.1*delta
		if TIMER.scale.x <= 0:
			die("Your timer ran out!")
	if ON_WATER > 0:
		HURTBOX.position.x += delta*SIDE_VELOCITY
		var watercheck = false
		for area in HURTBOX.get_overlapping_areas():
			if area.is_in_group("Water"):
				watercheck = true
		ON_WATER = watercheck
		if abs(HURTBOX.position.x) > MAX_WIDTH+0.7:
			die("You went too far down the stream!")
		if ON_LOGS == 0:
			die("You just fell into the water!", 0.1)
		
	SHAPE.global_position = SHAPE.global_position.move_toward(HURTBOX.position*Vector3(1,0,1), 10*delta)
	SHAPE.rotation = SHAPE.rotation.move_toward(HURTBOX.rotation, 20*delta)

func pause():
	PAUSED=true
	$MovePause.start()

func _on_move_pause_timeout():
	PAUSED=false
	

func _on_hurtbox_area_entered(area):
	if area.is_in_group("Water"):
		ON_WATER += 1
		SIDE_VELOCITY = area.get_parent().WATER_VELOCITY
	if area.is_in_group("Log"):
		ON_LOGS += 1
	if area.is_in_group("Lethal"):
		die("You just got hit by a car!")

func _on_hurtbox_area_exited(area):
	if area.is_in_group("Water"):
		ON_WATER -= 1
	if area.is_in_group("Log"):
		ON_LOGS -= 1

func die(message, delay=0):
	await get_tree().create_timer(delay).timeout
	dead.emit(message, HURTBOX.position)
	queue_free()
