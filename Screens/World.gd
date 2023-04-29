extends Node2D
const PlayerScene = preload("res://Actors/Player.tscn")
var player_spawn_location = Vector2.ZERO
@onready var camera: = $Camera2D
@onready var player: = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.set_default_clear_color(Color.LIGHT_BLUE)
	player.connect_camera(camera)
	player_spawn_location = player.global_position
	Events.connect("player_died", _on_player_died)
	Events.connect("hit_checkpoint", _on_hit_checkpoint)
	
func _on_player_died():
	var thisPlayer = PlayerScene.instantiate()
	thisPlayer.position = player_spawn_location
	add_child(thisPlayer)
	thisPlayer.connect_camera(camera)

func _on_hit_checkpoint(checkpoint_position):
	player_spawn_location = checkpoint_position
	
