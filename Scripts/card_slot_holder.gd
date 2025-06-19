extends Node2D
class_name CardSlotHolder;

@export var joker_slot_1 : Joker_Slot;
@export var joker_slot_2: Joker_Slot;

func set_joker_slot_1(index: int) -> void:
	joker_slot_1.set_joker_man(index);

func set_joker_slot_2(index: int) -> void:
	joker_slot_2.set_joker_man(index);
	
