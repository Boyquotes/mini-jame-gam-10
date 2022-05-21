extends Control


func _ready() -> void:
	$VBoxContainer/Quit.visible = not OS.get_name() == "HTML5"


func _on_Start_pressed() -> void:
	get_tree().change_scene("res://scenes/world/world.tscn")


func _on_Credits_pressed() -> void:
	$CreditsPop.popup_centered()


func _on_Quit_pressed() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func _on_RichTextLabel_meta_clicked(meta) -> void:
	OS.shell_open(meta)
