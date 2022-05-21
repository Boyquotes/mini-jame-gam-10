extends KinematicBody2D
class_name Enemy

signal died

export var speed: float
export var max_health: float
export var bullet: PackedScene
export var bullet_offset: float
export var drop: PackedScene
export var drop_chance: float

var target: KinematicBody2D
var is_dying := false

onready var health := max_health


func _ready() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]


func _on_Hitbox_area_entered(area: Area2D) -> void:
	if area.get("damage") == null:
		return
	health -= area.damage
	area.queue_free()
	if is_dying:
		return
	if health <= 0:
		$AnimationPlayer.play("die")
	else:
		$AnimationPlayer.play("hit")


func shoot_at_player() -> void:
	if is_dying:
		return
	if target:
		var b := bullet.instance()
		get_parent().add_child(b)
		b.global_position = position + global_position.direction_to(target.global_position) * bullet_offset
		b.shoot(global_position.direction_to(target.global_position))


func move_to_player() -> void:
	if is_dying:
		return
	if target:
		move_and_slide(global_position.direction_to(target.global_position) * speed)


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "die":
		emit_signal("died")
		if drop and randf() < drop_chance:
			var i := drop.instance()
			get_parent().add_child(i)
			i.position = position
		queue_free()
