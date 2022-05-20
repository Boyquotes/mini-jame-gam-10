extends Area2D


export var speed: float
var direction: Vector2


func _physics_process(delta: float) -> void:
	if speed and direction:
		position += speed * direction * delta


func shoot(d: Vector2) -> void:
	direction = d


func _on_Timer_timeout() -> void:
	queue_free()
