extends Node2D

@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("speedDownBuff")

func _process(delta: float) -> void:
	pass

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
