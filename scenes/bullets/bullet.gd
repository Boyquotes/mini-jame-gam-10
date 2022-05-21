extends Area2D


export var speed: float
export var damage: float
var direction: Vector2


func _physics_process(delta: float) -> void:
	if speed and direction:
		position += speed * direction * delta


func shoot(d: Vector2) -> void:
	direction = d
	rotation = direction.angle()


func _on_Timer_timeout() -> void:
	queue_free()
