extends Node2D
const AdventurerScene = preload("res://Actors/Adventurer.tscn")
var adventurer_spawn_location = Vector2.ZERO
@onready var camera: = $Camera2D
@onready var adventurer: = $Adventurer

# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.set_default_clear_color(Color.html('#69bfbb'))
	adventurer.connect_camera(camera)
	adventurer_spawn_location = adventurer.global_position
	
#	var rigidBody2d_a = $RigidBody2D
#	rigidBody2d_a.position = Vector2(2100,638)
#	add_child(rigidBody2d_a)
#
#	var rigidBody2d_b = $RigidBody2D
#	rigidBody2d_b.position = Vector2(2200,638)
#	add_child(rigidBody2d_b)
	
	
#	Events.connect("player_died", _on_player_died)
#	Events.connect("hit_checkpoint", _on_hit_checkpoint)
	
func _on_player_died():
	var thisAdventurer = AdventurerScene.instantiate()
	thisAdventurer.position = adventurer_spawn_location 
	add_child(thisAdventurer)
	thisAdventurer.connect_camera(camera)

func _on_hit_checkpoint(checkpoint_position):
	adventurer_spawn_location = checkpoint_position
