@tool
extends Path2D

enum ANIMATION_TYPE {
	LOOP,
	BOUNCE
}

@export var animation_type: = ANIMATION_TYPE.LOOP:
	get:
		return animation_type
	set(value):
		set_animation_type(value)
	
@export var speed = 1: 
	get:
		return speed
	set(value):
		speed = set_speed(value)
	

@onready var animationPlayer: = $AnimationPlayer

func set_animation_type(value):
	animation_type = value
	var ap = find_child("AnimationPlayer")
	if ap: play_updated_animation(ap)
	
func set_speed(value):
	pass
#	speed = value
#	var ap = find_child("AnimationPlayer")
#	if ap: ap.playback_speed = speed
	
#func _ready():
#	play_updated_animation(animationPlayer)
		
func play_updated_animation(ap):
	match animation_type:
		ANIMATION_TYPE.LOOP: ap.play("MoveAlongPathLoop")
		ANIMATION_TYPE.BOUNCE: ap.play("MoveAlongPathBouncing")
