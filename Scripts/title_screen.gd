extends CanvasLayer

const MAIN := preload("res://Scenes/Main.tscn")


func _ready():
	MessageBox.hide()
	$CenterContainer/VBoxContainer/Start.pressed.connect(_on_start_pressed)
	$CenterContainer/VBoxContainer/Quit.pressed.connect(_on_quit_pressed)
	
func _on_start_pressed():
	get_tree().change_scene_to_packed(MAIN)
	
func _on_quit_pressed():
	get_tree().quit()
	
