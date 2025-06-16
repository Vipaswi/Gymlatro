extends Control

@export var button_submit_1: Button
@export var button_submit_2: Button
@export var button_submit_3: Button

@export var weight_write_1: LineEdit # Or whatever type it is
@export var weight_write_2: LineEdit
@export var weight_write_3: LineEdit

@export var rep_write_1: LineEdit
@export var rep_write_2: LineEdit
@export var rep_write_3: LineEdit

@export var exercise_label: Label

@export var exercise_texture: TextureRect;

@export var animation_player: AnimationPlayer;

signal submit_data(weight: String, reps: String);

func _on_button_submit_1_button_up() -> void:
	print("button1 submission!");
	emit_signal("submit_data", weight_write_1.text, rep_write_1.text);


func _on_button_submit_2_button_up() -> void:
	emit_signal("submit_data", weight_write_2.text, rep_write_2.text);


func _on_button_submit_3_button_up() -> void:
	emit_signal("submit_data", weight_write_3.text, rep_write_3.text);
