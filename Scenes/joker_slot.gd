extends Node2D
class_name Joker_Slot

func set_joker_man(index: int) -> void:
	if index >= 0:
		%JokerMan.texture = load("res://Joker_Images/"+ str(index) + "_transparent.png");
	else:
		%JokerMan.texture = null;
