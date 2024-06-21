extends MeshInstance3D

@export var OBJECT : PackedScene

@export var TYPE : String
@export var VELOCITY : float = 1
var WATER_VELOCITY : float = VELOCITY
@export var MIN_DISTANCE = 3
var SPAWN_CHANCE : float = 100

var LEAVING : bool = false

func instantiate():
	pass

func initialize(t_index):
	position.z = t_index
	if not TYPE == "Water": 
		VELOCITY = randi_range(2, 5)*0.5
	else:
		VELOCITY = (t_index%4 + 2) *0.5
		WATER_VELOCITY = VELOCITY
	
	if TYPE=="Road" and randi_range(0,2)==1:
		rotation.y = PI
	
	if TYPE=="Water" and snapped(t_index/2, 1)%2 == 1:
		rotation.y = PI
		WATER_VELOCITY = -WATER_VELOCITY

func exit():
	LEAVING = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if TYPE == "Water":
		SPAWN_CHANCE += 18*delta
		if randf_range(0, 100) <= SPAWN_CHANCE:
			create()
			SPAWN_CHANCE = -50
	elif TYPE == "Road":
		SPAWN_CHANCE += 18*delta
		if randf_range(0, 100) <= SPAWN_CHANCE:
			create()
			SPAWN_CHANCE = -50
	if LEAVING:
		position.y -= 15 * delta
		if position.y < -50:
			queue_free()

func create():
	var object = OBJECT.instantiate()
	add_child(object)
	object.initialize(VELOCITY, $Spawn.position)
