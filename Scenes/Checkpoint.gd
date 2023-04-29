extends Area2D

@onready var animatedSprite: = $AnimatedSprite2D

func _on_body_entered(body):
	if not body is Player: return
	animatedSprite.animation = "checked"
	Events.emit_signal("hit_checkpoint",position)
