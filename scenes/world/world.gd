extends Node2D


export var cat_1: PackedScene
export var cat_2: PackedScene
export var mon_1: PackedScene
export var mon_2: PackedScene
export var mon_3: PackedScene
export var boss: PackedScene

onready var health := $CanvasLayer/Control/HBoxContainer/ProgressBar

var num_left := 0
var wave := 0
var dialogue := [
	[],
	[
		{
			"name": "Bun",
			"speech": "HEY YOU CATS! GIVE BACK MY PHONE!"
		},
		{
			"name": "Cat",
			"speech": "What do you mean? I don't have your phone-"
		},
		{
			"name": "Bun",
			"speech": "RRRRGH! TAKE THAT! GIVE IT BAAAAACK!"
		}
	],
	[
		{
			"name": "Bun",
			"speech": "WHERE IS MY PHONE?!"
		},
		{
			"name": "Big Cat",
			"speech": "Hey! What are you doing! Stop hitting my buddies!"
		}
	],
	[
		{
			"name": "Bun",
			"speech": "What's that? A monster? I must be on the right path to find my phone!"
		},
		{
			"name": "Sad Cat",
			"speech": "Don't say that about me! I'm just a weird-looking cat! *sob*"
		}
	],
	[
		{
			"name": "Sad Cat",
			"speech": "Guys, help me!!!"
		},
		{
			"name": "Bun",
			"speech": "Which one of you monsters has my phone?!"
		},
		{
			"name": "Very Sad Cat",
			"speech": "We're not monsters..."
		}
	],
	[
		{
			"name": "Bun",
			"speech": "Wow, reality is breaking! I'm close to my phone! I can feel it!"
		},
		{
			"name": "Red Cat",
			"speech": "Why would we even want your phone?!"
		}
	],
	[
		{
			"name": "Bun",
			"speech": "Phone! I found you!"
		},
		{
			"name": "Phone",
			"speech": "You jerk! I ran away because you kept beating innocent people up!"
		},
		{
			"name": "Bun",
			"speech": "What do you mean? They're monsters!"
		},
		{
			"name": "Phone",
			"speech": "You're the real monster!"
		},
		{
			"name": "Bun",
			"speech": "I'll beat you until you change your mind!"
		}
	]
]
var index := -1

func _ready() -> void:
	randomize()
	set_process_unhandled_input(false)
	health.max_value = $Player2D.max_health
	health.value = $Player2D.health
	advance_wave()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if $CanvasLayer/Control/Dialogue/HBoxContainer/VBoxContainer/Speech/Timer.is_stopped():
			advance_dialogue()
		else:
			$CanvasLayer/Control/Dialogue/HBoxContainer/VBoxContainer/Speech.percent_visible = 1.0
			$CanvasLayer/Control/Dialogue/HBoxContainer/VBoxContainer/Speech/Timer.stop()

func _on_Player2D_player_health_changed() -> void:
	health.value = $Player2D.health


func _on_Player2D_player_died() -> void:
	$CanvasLayer/Control/GameOver.show()


func _on_Button_pressed() -> void:
	get_tree().change_scene("res://scenes/title/title.tscn")


func spawn_enemy(enemy: PackedScene) -> void:
	var loc := get_spawn_loc()
	while Rect2(0, 0, 480, 270).has_point(loc):
		loc = get_spawn_loc()
	var instance := enemy.instance()
	add_child(instance)
	instance.position = loc
	instance.connect("died", self, "on_enemy_died")


func get_spawn_loc() ->Vector2:
	return Vector2(
		rand_range(-100, 580),
		rand_range(-100, 370)
	)


func spawn_wave(num: int) -> void:
	match num:
		1:
			num_left = 10
			for _i in range(10):
				spawn_enemy(cat_1)
		2:
			num_left = 10
			for _i in 8:
				spawn_enemy(cat_1)
			for _i in 2:
				spawn_enemy(cat_2)
		3:
			num_left = 10
			for _i in 3:
				spawn_enemy(cat_1)
			for _i in 4:
				spawn_enemy(cat_2)
			for _i in 3:
				spawn_enemy(mon_1)
		4:
			num_left = 10
			for _i in 1:
				spawn_enemy(cat_1)
			for _i in 2:
				spawn_enemy(cat_2)
			for _i in 5:
				spawn_enemy(mon_1)
			for _i in 2:
				spawn_enemy(mon_2)
		5:
			num_left = 15
			for _i in 1:
				spawn_enemy(cat_1)
			for _i in 2:
				spawn_enemy(cat_2)
			for _i in 3:
				spawn_enemy(mon_1)
			for _i in 5:
				spawn_enemy(mon_2)
			for _i in 4:
				spawn_enemy(mon_3)
		6:
			num_left = 1
			spawn_enemy(boss)


func on_enemy_died() -> void:
	num_left -= 1
	if num_left == 0:
		advance_wave()


func advance_wave() -> void:
	wave += 1
	if wave == 5:
		$Background.texture = preload("res://scenes/world/BG2.png")
	index = -1
	if wave == 7:
		$Background.texture = preload("res://scenes/world/BG1.png")
		$CanvasLayer/Control/GameOver/Label.text = "YOU WIN?!"
		$CanvasLayer/Control/GameOver.show()
		return
	if wave < dialogue.size() and dialogue[wave]:
		$CanvasLayer/Control/Dialogue.show()
		set_process_unhandled_input(true)
		advance_dialogue()
	else:
		spawn_wave(wave)


func advance_dialogue() -> void:
	index += 1
	if index == dialogue[wave].size():
		$CanvasLayer/Control/Dialogue.hide()
		set_process_unhandled_input(false)
		spawn_wave(wave)
		return
	$CanvasLayer/Control/Dialogue/HBoxContainer/VBoxContainer/Name.text = dialogue[wave][index].name
	$CanvasLayer/Control/Dialogue/HBoxContainer/VBoxContainer/Speech.text = dialogue[wave][index].speech
	match dialogue[wave][index].name:
		"Bun":
			$CanvasLayer/Control/Dialogue/HBoxContainer/Image.texture = preload("res://scenes/players/front_2.png")
		"Cat":
			$CanvasLayer/Control/Dialogue/HBoxContainer/Image.texture = preload("res://scenes/enemies/cat1.png")
		"Big Cat":
			$CanvasLayer/Control/Dialogue/HBoxContainer/Image.texture = preload("res://scenes/enemies/cat2.png")
		"Sad Cat":
			$CanvasLayer/Control/Dialogue/HBoxContainer/Image.texture = preload("res://scenes/enemies/mon1.png")
		"Very Sad Cat":
			$CanvasLayer/Control/Dialogue/HBoxContainer/Image.texture = preload("res://scenes/enemies/mon2.png")
		"Red Cat":
			$CanvasLayer/Control/Dialogue/HBoxContainer/Image.texture = preload("res://scenes/enemies/mon3.png")
		"Phone":
			$CanvasLayer/Control/Dialogue/HBoxContainer/Image.texture = preload("res://scenes/enemies/Phone_boss.png")
	$CanvasLayer/Control/Dialogue/HBoxContainer/VBoxContainer/Speech.visible_characters = 0
	$CanvasLayer/Control/Dialogue/HBoxContainer/VBoxContainer/Speech/Timer.start()


func _on_Timer_timeout() -> void:
	$CanvasLayer/Control/Dialogue/HBoxContainer/VBoxContainer/Speech.visible_characters += 1
	if not $CanvasLayer/Control/Dialogue/HBoxContainer/VBoxContainer/Speech.percent_visible == 1.0:
		$CanvasLayer/Control/Dialogue/HBoxContainer/VBoxContainer/Speech/Timer.start()
