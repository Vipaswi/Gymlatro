extends Node2D
class_name CardSlotHolder;

@export var joker_slot_1 : Joker_Slot;
@export var joker_slot_2: Joker_Slot;

@export var animation_player : AnimationPlayer;

func get_label() -> Label:
	return %Label_Animation;

func play_slot_animation(slot_index: int):
	if slot_index == 0:
		animation_player.play("First_Slot_Anim")
	else:
		animation_player.play("Second_Slot_Anim")
	
	await animation_player.animation_finished;

func set_joker_slot_1(index: int) -> void:
	joker_slot_1.set_joker_man(index);

func set_joker_slot_2(index: int) -> void:
	joker_slot_2.set_joker_man(index);

func set_joker_slot(slot_index: int, index: int) -> void:
	if slot_index == 0:
		joker_slot_1.set_joker_man(index);
	else:
		joker_slot_2.set_joker_man(index);
