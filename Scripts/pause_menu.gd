extends CanvasLayer


const TITLE_SCREEN := preload("res://Scenes/UI Elements/TitleScreen.tscn")

func _ready() -> void:
	var mat := $BlurBG.material as ShaderMaterial
	mat.set_shader_parameter("screen_size", get_viewport().get_visible_rect().size)
	print("TITLE_SCREEN is valid:", TITLE_SCREEN)
	hide()
	get_tree().paused = false
	
	$CenterContainer/VBoxContainer/Resume.pressed.connect(func(): resume())
	$CenterContainer/VBoxContainer/Title.pressed.connect(func(): call_deferred("return_to_title"))
	
func resume():
	hide()
	get_tree().paused = false
	
func return_to_title():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI Elements/TitleScreen.tscn")
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and GameState.menu_type == GameState.MenuType.NONE:
		print("pause pressed")
		if visible:
			resume()
		else:
			show()
			get_tree().paused = true
