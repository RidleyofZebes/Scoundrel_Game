extends CanvasLayer


@onready var label = $CenterContainer/VBoxContainer/Label

const TITLE_SCREEN := preload("res://Scenes/UI Elements/TitleScreen.tscn")

func _ready() -> void:
	print("TITLE_SCREEN is valid:", TITLE_SCREEN)
	hide()
	get_tree().paused = false
	
	$CenterContainer/VBoxContainer/Retry.pressed.connect(func(): resume())
	$CenterContainer/VBoxContainer/Quit.pressed.connect(func(): call_deferred("return_to_title"))
	
func show_death(message: String = "Oops..."):
	label.text = message
	show()
	get_tree().paused = true
	
func resume():
	hide()
	get_tree().paused = false
	
func return_to_title():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI Elements/TitleScreen.tscn")
