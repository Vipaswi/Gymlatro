extends Control

# Buttons
@onready var left_button : Button = %LeftButton;
@onready var right_button : Button = %RightButton;

# Label 
@onready var progress_label : Label = %Progress;

# Card
@onready var joker_image : TextureButton = %JokerImage;

# Current Card
var current_card_index : int;
var power_up_one: int;
var power_up_two: int;

#Card Images:
var jokers; # Array to hold images
var joker_indexes : Array[int]; # Array of current joker indexes

signal selected_joker(card_index: int);

#Powerups
const powerups = [0,1,2,3,4] 
	#0  : +5 Reps for every exercise (Ronnie Coleman)
	#1  : +5 Weight for leg exercises (Chicken joker muscles)
	#2  : +5 Weight for arm exercises (Hulk Joker)
	#3  : +100 mult on last exercise (Sam Sulek failure)
	#4  : Extra death allowed (Jacked up Death)
	
func _ready() -> void :
	# Load all jokers as images 
	var stringFormat = "res://Joker_Images/%s.png";
	
	# Initialize
	jokers = [];
	joker_indexes.resize(2);
	
	# Fill
	for i in range(0, powerups.size()):
		var resource = load(stringFormat % str(i));
		if resource is Resource:
			jokers.append(resource);
			print("loaded: " + str(i) + " into marketplace");
	
	#Disable
	left_button.disabled = true;
	
	reset_marketplace();
	
func reset_marketplace() -> void:
	# Get Two From the Marketplace
	power_up_one = randi() % powerups.size();
	power_up_two = randi() % powerups.size();
	
	# Ensure Indexes are recorded
	joker_indexes.set(0,power_up_one);
	joker_indexes.set(1, power_up_two);
	
	print("Joker indexes in the marketplace are: " + str(power_up_one) + " " + str(power_up_two));
	
	# Set Variable
	current_card_index = 0;
	
	update_joker_image_texture();

func update_joker_image_texture() -> void:
	joker_image.texture_normal = jokers.get(joker_indexes.get(current_card_index)); #Initially Show powerup one
	progress_label.text = str((current_card_index + 1)) + "/2";

func _on_left_button_button_up() -> void:
	current_card_index -= 1;
	left_button.disabled = current_card_index == 0;
	right_button.disabled = false;
	update_joker_image_texture();

func _on_right_button_button_up() -> void:
	current_card_index += 1;
	left_button.disabled = false;
	right_button.disabled = current_card_index == 1; #disable
	update_joker_image_texture();


func _on_select_button_up() -> void:
	self.hide();
	emit_signal("selected_joker", joker_indexes.get(current_card_index));
	print("Selected Joker is: " + str(joker_indexes.get(current_card_index)));
	
