extends Node3D

var played = false
func _ready() -> void:
		$Explosion/AnimationPlayer.play("PlayExplosion")
		await get_tree().create_timer(6).timeout
		queue_free()
