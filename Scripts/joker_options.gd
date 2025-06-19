extends MenuButton
# JokerCard.gd
# (The rest of your script, extends Control, signals, @onready vars, etc.)

func _ready() -> void:
	# Get the PopupMenu from the MenuButton
	var popup_menu: PopupMenu = get_popup()
	if popup_menu:
		
		popup_menu.add_item("Sell", 1, 0) 
		popup_menu.add_item("Info", 2, 1) 
		
		popup_menu.theme = preload("res://Themes/lineedit.tres"); 

		# Connect the signal from the PopupMenu
		popup_menu.item_pressed.connect(Callable(self, "_on_popup_menu_item_pressed"))



#Signals handled by Node2D
func _on_popup_item_pressed(id: int):
	match id:
		1:
			print("Information Selected");
			emit_signal("JokerInfo");
		2:
			print("Option 2 selected!");
			emit_signal("SellJoker");
