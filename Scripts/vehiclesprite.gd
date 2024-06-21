extends Node3D

var rng = RandomNumberGenerator.new()
var BODIES=[]
var BODY=[]

# Called when the node enters the scene tree for the first time.
func setbody():
	BODIES=[$Car1,$Car2,$Car3,$Car4]
	BODY=BODIES[rng.randi_range(0,3)]
	BODY.visible = true
	if rng.randi_range(0,2) == 1:
		BODY.get_surface_override_material(0).albedo_texture = load("res://Assets/Models/VehicleTex2.png")
	
