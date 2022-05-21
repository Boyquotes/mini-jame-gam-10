extends Enemy


func _ready() -> void:
	$AnimationPlayer.play("bounce")


func _physics_process(_delta: float) -> void:
	move_to_player()


func _on_Timer_timeout() -> void:
	shoot()


func shoot() -> void:
	if is_dying:
		return
	if target:
		for i in 10:
			var b := bullet.instance()
			get_parent().add_child(b)
			b.global_position = position + global_position.direction_to(target.global_position) * bullet_offset
			b.shoot(Vector2.RIGHT.rotated(2 * PI / 10 * i))
