extends Node

var DEAD : bool = false
var RESET : bool = false
var loading : bool = true

var LOAD_DESTINATION: float = 540

var LOADRANGE = 30

var HIGHSCORE_D = 0
var HIGHSCORE_V = 0

var DISTANCE_TRAVELED : int = 0
var OBJECTS_BROKEN : int = 0
var TERRAIN = []

var WATER : PackedScene = preload("res://Scenes/Terrain/Water.tscn")
var ROAD : PackedScene = preload("res://Scenes/Terrain/Road.tscn")
var GRASS : PackedScene = preload("res://Scenes/Terrain/Grass.tscn")

var NEXTTERRAIN : PackedScene = preload("res://Scenes/Terrain/Grass.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if FileAccess.file_exists("user://CrissCrossScores.json"):
		var savetext = FileAccess.get_file_as_string("user://CrissCrossScores.json")
		var savedata = JSON.parse_string(savetext)
		var last_distance = 0
		var last_objects = 0
		HIGHSCORE_D = 0
		HIGHSCORE_V = 0
		if savedata != null:
			last_distance = savedata['DisLast']
			last_objects = savedata['ObjLast']
			HIGHSCORE_D = savedata['Dis']
			HIGHSCORE_V = savedata['Obj']
		$Distance.text =  " [color=#55bbff]Score: "+str(last_distance)+"\n[font_size=40]	Best: "+str(HIGHSCORE_D)
		$Objects.text =  " [color=#ff6600]Broken Objects: "+str(last_objects)+"\n[font_size=40]	Best: "+str(HIGHSCORE_V)
	else:
		$Distance.text =  " [color=#55bbff]Score: "+str(0)+"\n[font_size=40]	Best: "+str(0)
		$Objects.text =  " [color=#ff6600]Broken Objects: "+str(0)+"\n[font_size=40]	Best: "+str(0)
		
		
	
	$OhNoMessage.text = "[right] Criss Cross    1\n[font_size=60]Use arrow keys to move         1
	[font_size=40]R/F = punch               1
	E/D = kick               1
	W/S = throw               1
	Space = leap               1"
	for t_index in range(-3, LOADRANGE+1, 1):
		create_terrain(t_index)
		if (t_index > 2):
			randomize_terrain()
	
	await get_tree().create_timer(0.5).timeout
	LOAD_DESTINATION = -540
	$Frog.MOBILE = true
	$Beep.wait_time = randf_range(0.3, 40)
	$Beep.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not DEAD:
		$Camera3D.position.z = $Frog.SHAPE.position.z - 16
	$LoadingCover.position = $LoadingCover.position.move_toward(Vector2(960,LOAD_DESTINATION), delta*2160)
	
	$Score.text = " [color=#55bbff]"+str(DISTANCE_TRAVELED)+"\n [color=#ff6600]"+str(OBJECTS_BROKEN)


func _on_frog_moved(dist):
	enter(false)
	if dist > DISTANCE_TRAVELED:
		DISTANCE_TRAVELED = dist
		TERRAIN[0].exit()
		TERRAIN.remove_at(0)
		$Frog.TIMER.scale.x = clamp($Frog.TIMER.scale.x+0.1, 0, 1)
		$Frog.POWER.scale.x = clamp($Frog.POWER.scale.x+0.1, 0, 1)
		
		randomize_terrain()
		create_terrain(dist+LOADRANGE)

func create_terrain(dist):
	var nextterrain = NEXTTERRAIN.instantiate()
	add_child(nextterrain)
	nextterrain.initialize(dist)
	TERRAIN.append(nextterrain)

func randomize_terrain():
	var randint = randi_range(0, 20)
	if randint > 18:
		NEXTTERRAIN = GRASS
	elif randint > 16:
		NEXTTERRAIN = WATER
	elif randint > 12:
		NEXTTERRAIN = ROAD
	elif NEXTTERRAIN == GRASS and randint > 5:
		NEXTTERRAIN = ROAD


func _on_frog_dead(message, pos):
	DEAD = true
	enter(true)
	
	if FileAccess.file_exists("user://CrissCrossScores.json"):
		var savetext = FileAccess.get_file_as_string("user://CrissCrossScores.json")
		var savedata = JSON.parse_string(savetext)
		HIGHSCORE_D = 0
		HIGHSCORE_V = 0
		
		await get_tree().create_timer(.1).timeout
		if savedata != null:
			HIGHSCORE_D = savedata['Dis']
			HIGHSCORE_V = savedata['Obj']
	
	$OhNoMessage.text = "[right] Oh no!    1\n[font_size=60]"+message+"         1\n[font_size=40] press R to try again                0"
	if DISTANCE_TRAVELED > HIGHSCORE_D:
		$Distance.text =  " [color=#55bbff]Score: "+str(DISTANCE_TRAVELED)+"\n[wave amp=60 freq=10][rainbow freq=2 sat=0.5][font_size=40]	New high score!"
	else:
		$Distance.text =  " [color=#55bbff]Score: "+str(DISTANCE_TRAVELED)+"\n[font_size=40]	Best: "+str(HIGHSCORE_D)
	if OBJECTS_BROKEN > HIGHSCORE_V:
		$Objects.text = " [color=#ff6600]Broken Objects: "+str(OBJECTS_BROKEN)+"\n[wave amp=60 freq=10][rainbow freq=2 sat=0.5][font_size=40]	New high score!"
	else:
		$Objects.text =  " [color=#ff6600]Broken Objects: "+str(OBJECTS_BROKEN)+"\n[font_size=40]	Best: "+str(HIGHSCORE_V)
	blast(pos)
	var path = "user://CrissCrossScores.json"
	var savedata = {
		"Dis" = maxi(HIGHSCORE_D, DISTANCE_TRAVELED),
		"Obj" = maxi(HIGHSCORE_V, OBJECTS_BROKEN),
		"DisLast" = DISTANCE_TRAVELED,
		"ObjLast" = OBJECTS_BROKEN
	}
	savedata = JSON.stringify(savedata)
	var save_game = FileAccess.open(path, FileAccess.WRITE)
	save_game.store_line(savedata)
	print('saved')
	await get_tree().create_timer(.5).timeout
	$Death.play()
	await get_tree().create_timer(.5).timeout
	RESET = true
	enter(true)

func blast(pos):
	var explosion = preload("res://Scenes/explosion_effect.tscn").instantiate()
	add_child(explosion)
	explosion.position = pos
	$AudioStreamPlayer.volume_db= -0.8 - (pos.z - DISTANCE_TRAVELED)/1.5
	$AudioStreamPlayer.play()

func _unhandled_input(event):
	if event.is_action_pressed("Punch") and RESET:
		LOAD_DESTINATION = 540
		await get_tree().create_timer(0.5).timeout
		get_tree().reload_current_scene()
	if event.is_action_pressed("Esc"):
		await get_tree().create_timer(0.8).timeout 
		get_tree().quit()

func enter(out):
	for textbox in [$Distance, $Objects, $OhNoMessage]:
		textbox.enter(out)
	$Distance.enter(out)


func _on_beep_timeout():
	$Beepsound.volume_db = randf_range(3, 7)
	$Beepsound.play()
	$Beep.wait_time = randf_range(0.3, 40)
	$Beep.start()
