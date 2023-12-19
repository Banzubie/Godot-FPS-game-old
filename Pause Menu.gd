extends Control

var paused = false

	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		pauseMenu()
		
func _on_resume_pressed():
	pauseMenu()
	
func pauseMenu():
	if !paused:
		show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = not get_tree().paused
	else:
		hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = not get_tree().paused
	paused = !paused

func _on_main_menu_pressed():
	get_tree().paused = not get_tree().paused
	get_tree().change_scene_to_file("res://scenes/main_screen.tscn")


func _on_quit_pressed():
	get_tree().quit()
