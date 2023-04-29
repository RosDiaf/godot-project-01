extends ParallaxLayer

@export var CLOUD_SPEED: float = -15

func _process(delta):
	motion_offset.x += CLOUD_SPEED * delta
