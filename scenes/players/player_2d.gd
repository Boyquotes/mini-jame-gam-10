extends KinematicBody2D


signal player_died
signal player_health_changed

export var speed: float
export var can_accelerate: bool
export var acceleration: float
export var friction: float
export var apply_gravity: bool
export var gravity: float
export var jump_force: float
export var max_health: float
export var bullet: PackedScene
export var bullet_offset: float
export var big_bullet: PackedScene

var velocity := Vector2.ZERO
var is_dying := false
var use_bb := false
var use_shield := false

onready var health := max_health


func _physics_process(delta: float) -> void:
	if is_dying:
		return
	var input := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	if can_accelerate:
		if input.x:
			velocity.x = move_toward(velocity.x, input.x * speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)
	else:
		velocity.x = input.x * speed
	if apply_gravity:
		velocity.y += gravity * delta
		if input.y < 0 and is_on_floor():
			velocity.y = -jump_force
	else:
		if can_accelerate:
			if input.y:
				velocity.y = move_toward(velocity.y, input.y * speed, acceleration * delta)
			else:
				velocity.y = move_toward(velocity.y, 0, friction * delta)
		else:
			velocity.y = input.y * speed
	velocity = move_and_slide(velocity, Vector2.UP)
	
	$Sprite.playing = not input == Vector2.ZERO
	if input.x < 0:
		$Sprite.play("side")
		$Sprite.flip_h = true
	elif input.x > 0:
		$Sprite.play("side")
		$Sprite.flip_h = false
	elif input.y < 0:
		$Sprite.play("back")
	elif input.y > 0:
		$Sprite.play("front")


func _unhandled_input(event: InputEvent) -> void:
	if is_dying:
		return
	if event.is_action_pressed("left_click"):
		$FireTimer.start()
		fire()
	elif event.is_action_released("left_click"):
		$FireTimer.stop()
		

func fire() -> void:
	$Shoot.play()
	var b
	if not use_bb:
		b = bullet.instance()
	else:
		b = big_bullet.instance()
	get_parent().add_child(b)
	b.global_position = position + global_position.direction_to(get_global_mouse_position()) * bullet_offset
	b.shoot(global_position.direction_to(get_global_mouse_position()))


func _on_FireTimer_timeout() -> void:
	fire()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "die":
		emit_signal("player_died")
		queue_free()


func _on_DropPickup_area_entered(area: Area2D) -> void:
	if not area.get("id"):
		area.queue_free()
		return
	$Powerup.play()
	match area.id:
		"heal":
			health += 1
			emit_signal("player_health_changed")
		"heal_2":
			health += 2
			emit_signal("player_health_changed")
		"big":
			use_bb = true
			$BBTimer.start()
		"shield":
			use_shield = true
			$ShieldTimer.start()
			$Shield.show()
		"rapid":
			$FireTimer.wait_time = 0.1
			$RapidTimer.start()
	area.queue_free()


func _on_BBTimer_timeout() -> void:
	use_bb = false


func _on_ShieldTimer_timeout() -> void:
	use_shield = false
	$Shield.hide()


func _on_RapidTimer_timeout() -> void:
	$FireTimer.wait_time = 0.2


func _on_Hitbox_area_entered(area: Area2D) -> void:
	check_damage(area)

func check_damage(area: Area2D) -> void:
	if area.get("damage") == null:
		return
	if $InvincTimer.is_stopped() and not use_shield:
		health -= area.damage
		emit_signal("player_health_changed")
	if area.is_in_group("bullet"):
		area.queue_free()
	if is_dying:
		return
	if health <= 0:
		$Hit.play()
		is_dying = true
		for enemy in get_tree().get_nodes_in_group("enemy"):
			enemy.target = null
		$AnimationPlayer.play("die")
	elif $InvincTimer.is_stopped() and not use_shield:
		$Hit.play()
		$AnimationPlayer.play("flash")
		$InvincTimer.start()


func _on_InvincTimer_timeout() -> void:
	for area in $Hitbox.get_overlapping_areas():
		check_damage(area)
		break
