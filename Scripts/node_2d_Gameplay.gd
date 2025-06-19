extends Node2D

#playButton
func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("SubViewportContainer/SubViewport/Node2d")
	print("clicked button")
	
