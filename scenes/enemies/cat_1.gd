extends Enemy


func _ready() -> void:
	$AnimationPlayer.play("bounce")


func _physics_process(_delta: float) -> void:
	move_to_player()


func _on_Timer_timeout() -> void:
	shoot_at_player()
