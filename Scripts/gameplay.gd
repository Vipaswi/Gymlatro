extends Node2D

#The Essentials - Game Specific State
var is_playing: bool;
var current_score: int;
var ante: int;
var ante_score: int;
var round_count : int;
var display_round: int; #bet. 1 and 3
var max_score: int; 
var total_score: int;

#Exercise String Variables:
var exercise_array: PackedStringArray;
var current_exercise_name : String;

# Button Variables:
var button_array; #an array of size 2 (corresponding to each card;)
var input_weight_array; #an array of size 2  (corresponding ot each card) 
var input_rep_array; #an array of size 2 (corresponding ot each card)
var submitted: int; #a number from 0 to button_array.size() (3) counting submitted rep, weights

# Animation Variables
var transition_player;
var cards : Array; #animation_player array
var current_card_index: int;
var transition_complete: bool;
var _score_animation_tween: Tween;

# Scene Control
var Card1Control;
var Card2Control;
var lose_screen;

# Lose Condition Scene Signals
# -> Used to set values
signal set_max_score(max_score: int);
signal set_ante(ante: int);
signal set_round(round_count: int);
signal set_total_score(total_score: int);

# Preloaded Exercise Images:
var imageDictionary: Dictionary;

# To Avoid Redundancy:
# -> helps avoid re-establishing signal connections
# -> and loading content again
@onready var run_already = 0;

# Jokers:
var jokers_array: Array[int]; # An array of size two holding each of the jokers
var joker_to_replace: int; # The current joker slot to be replaced 

# Joker rel. Variables
var extra_lives: int; # For death joker

# The amount of jokers (changing this will not dynamically change the slots)
const JOKER_SLOT_AMOUNT: int = 2;

# Joker Powerup Values
const YEAH_BUDDY_JOKER = 0;
const CHICKEN_JOKER = 1;
const GREEN_JOKER = 2;
const PLOT_ARMOR_JOKER = 3;
const DEATH_JOKER_INDEX: int = 4;

# Card Slot holder
@onready var card_slot_holder = %CardSlotHolder;

# The Marketplace
var marketplace_scene;
var marketplace_instance;

#initialize starting conditions
func _ready() -> void:
	set_initial_conditions();

#initial conditions for reusability
func set_initial_conditions() -> void:
	#Initial Variable Conditions
	is_playing = true;
	max_score = 0;
	total_score = 0;
	transition_complete = true;
	_score_animation_tween = null;
	Card1Control = %Card1Control;
	Card2Control = %Card2Control;
	lose_screen = %YouLoseControl;
	extra_lives = 0;
	
	# Joker Instantiations:
	jokers_array.resize(JOKER_SLOT_AMOUNT);
	
	# Make negative
	jokers_array[0] = -1;
	jokers_array[1] = -1;
	
	#Pre load the marketplace
	marketplace_scene = preload("res://Scenes/marketplace.tscn");
	marketplace_instance = marketplace_scene.instantiate();
	get_tree().root.add_child(marketplace_instance);
	marketplace_instance.selected_joker.connect(add_joker);
	marketplace_instance.hide();
	
	
	#hide LoseScene
	lose_screen.visible = false;
	lose_screen.z_index = -1;
	
	#connect signals
	if run_already == 0:
		Card1Control.submit_data.connect(on_submit);
		Card2Control.submit_data.connect(on_submit);
		run_already = 1;
	
	#set stage for animationsn and initial positions
	set_animation_properties();
	await play_transition("init");
	Card1Control.animation_player.play("RESET");
	Card2Control.animation_player.play("RESET");
	
	await Card1Control.animation_player.animation_finished;
	await Card2Control.animation_player.animation_finished;
	
	#buttons:
	set_button_array();
	disable_all_buttons(0);
	disable_all_buttons(1);
	enable_next(0, 0); 
	enable_next(0, 1); 
	
	#reset inputs - for previous playthrough wipes
	reset_inputs();
	
	#scores and exercises:
	reset_scores();
	get_exercises();
	get_new_random_card();
	flip_card();
	

func set_animation_properties() -> void:
	transition_player = %TransitionPlayer; #set the transition.
	cards = [Card1Control.animation_player, Card2Control.animation_player];
	current_card_index = 0; #the first card;

func play_transition(transitionName: String) -> void:
	transition_player.play(transitionName);
	await transition_player.animation_finished;
	
	
func reset_scores() -> void:
	current_score = 0;
	ante = 1;
	ante_score = 800;
	submitted = 0;
	round_count = 1;
	

#displays the try info
func display_loss() -> void:
	emit_signal("set_ante", ante);
	emit_signal("set_max_score", max_score);
	emit_signal("set_round", round_count);
	emit_signal("set_total_score", total_score);
	lose_screen.z_index = 0;
	lose_screen.visible = true;
	
#Gets the exercises from the text file
func get_exercises() -> void:
	var file = FileAccess.open("res://exercises/fiveExerciseList.txt", FileAccess.READ);
	var exerciseString = file.get_as_text();
	if(exerciseString.length() <= 0):
		push_error("No exercises to read from");
	exercise_array = exerciseString.split("\n", false);
	file.close();
	
	imageDictionary = {};
	#preload exercises
	for i in range(0, exercise_array.size()):
		var resource = load("res://Exercise_Images/%s.png" % exercise_array.get(i))
		if resource is Resource:
			imageDictionary.set(exercise_array.get(i), resource);

#is responsible for returning a new random card from the file system
func get_new_random_card() -> void:
	var randomInt = randi() % exercise_array.size();
	current_exercise_name = exercise_array.get(randomInt);
	
	var imageTexture = imageDictionary.get(current_exercise_name);
	
	var cardDisplay = Card1Control.exercise_texture if current_card_index == 0 else Card2Control.exercise_texture;
	cardDisplay.texture = imageTexture;

func flip_card() -> void:
	cards[current_card_index].play("CardFlip"); #Flip the current
	await cards[current_card_index].animation_finished; 

#Sets the text for all the labels based on game state
func setLabelText() -> void:
	var userScore = %Label4;
	userScore.text = str(ante_score);
	
	var anteCount = %Label6;
	anteCount.text = str(ante);
	
	#set labels for both
	var exerciseLabel = Card1Control.exercise_label;
	exerciseLabel.text = current_exercise_name;
	
	var exerciseLabel2 = Card2Control.exercise_label;
	exerciseLabel2.text = current_exercise_name;
	
	var current_scoreLabel = %CurrentScore;
	current_scoreLabel.text = str(current_score);
	
	var roundLabel = %RoundLabel;
	roundLabel.text = str(round_count);
	
func set_button_array() -> void:
	# --- Card 1 Controls ---
	var buttonSubmit1 = Card1Control.button_submit_1; 
	var buttonSubmit2 = Card1Control.button_submit_2;
	var buttonSubmit3 = Card1Control.button_submit_3;
	
	var weightWrite1 = Card1Control.weight_write_1;
	var weightWrite2 = Card1Control.weight_write_2
	var weightWrite3 = Card1Control.weight_write_3;
	
	var repWrite1 = Card1Control.rep_write_1;
	var repWrite2 = Card1Control.rep_write_2;
	var repWrite3 = Card1Control.rep_write_3;
	
	# --- Card 2 Controls ---
	var buttonSubmit1_2 = Card2Control.button_submit_1;
	var buttonSubmit2_2 = Card2Control.button_submit_2;
	var buttonSubmit3_2 = Card2Control.button_submit_3;
	
	var weightWrite1_2 = Card2Control.weight_write_1;
	var weightWrite2_2 = Card2Control.weight_write_2;
	var weightWrite3_2 = Card2Control.weight_write_3;
	
	var repWrite1_2 = Card2Control.rep_write_1;
	var repWrite2_2 = Card2Control.rep_write_2;
	var repWrite3_2 = Card2Control.rep_write_3;
	
	# --- Arrays ---
	button_array = [
		[buttonSubmit1, buttonSubmit2, buttonSubmit3],
		[buttonSubmit1_2, buttonSubmit2_2, buttonSubmit3_2]
	]
	
	input_weight_array = [
		[weightWrite1, weightWrite2, weightWrite3],
		[weightWrite1_2, weightWrite2_2, weightWrite3_2]
	]
	
	input_rep_array = [
		[repWrite1, repWrite2, repWrite3],
		[repWrite1_2, repWrite2_2, repWrite3_2]
	]

func update_stats() -> void:
	#Increas ante and round
	ante_score = ante * 100 + ante_score;
	round_count = round_count + 1; #increase round_count
	
	var newAnte: bool = round_count % 3 == 1 and round_count != 1;
	
	ante = ante + (1 if newAnte else 0);
	
	#reset
	current_score = 0;
	submitted = 0;

func switch_card_focus() -> void:
	if(current_card_index == 0):
		Card2Control.animation_player.play("RESET");
		await play_transition("animate1");
	else:
		Card1Control.animation_player.play("RESET");
		await play_transition("loopcard1");
	
	reset_inputs(); #reset input after animation completion
	current_card_index = 1 - current_card_index; 
	
	get_new_random_card();
	await flip_card();
	
#basically our main game logic
func _process(_delta: float) -> void:
	if(is_playing):
		#win condition
		setLabelText();

func reset_inputs() -> void:
	for i in range(0, button_array[current_card_index].size()):
		button_array[current_card_index][i].disabled = false;
		button_array[current_card_index][i].add_theme_color_override("white_font", Color(1,1,1,1));
	
	for i in range(0, input_rep_array[current_card_index].size()):
		input_rep_array[current_card_index][i].text = ""; #reset to nothing
		
	for i in range(0, input_weight_array[current_card_index].size()):
		input_weight_array[current_card_index][i].text = ""; #reset to nothing	
		
	disable_all_buttons(current_card_index);
	enable_next(0, current_card_index);

func set_reps_mult_text(reps: String, weight: String) -> void:
	#convert for sub anim
	%RepsChips.text = str(reps);
	%WeightMult.text = str(weight);

func activate_marketplace() -> void:
	var newAnte: bool = (round_count % 3 == 0);
	
	# Avoid Redundancy
	if(newAnte and run_already != 0):
		marketplace_instance.reset_marketplace();
	
	if(newAnte):
		marketplace_instance.show();
		await marketplace_instance.hidden;

func animateOnSubmit(reps: int, weight: int) -> void:
	#convert for sub anim
	set_reps_mult_text(str(reps), str(weight));
	
	print("Reps is: " + str(reps));
	print("Weight is: " + str(weight));
	
	# TODO: Show Rep and Mult from NewScore, and leave it there
	%ScorePlayer.play("NewScore");
	await %ScorePlayer.animation_finished;
	
	# Animate Joker stuff
	var rep_weight_arr = await handle_jokers(reps, weight);
	
	var joker_altered_reps = rep_weight_arr[0];
	var joker_altered_weight = rep_weight_arr[1];
	
	print("New Reps is: " + str(joker_altered_reps));
	print("New Weight is: " + str(joker_altered_weight));
	
	#play sub anim
	%ScorePlayer.play("add_to_scoreboard");
	await %ScorePlayer.animation_finished;
	
	#calculate properties of anim
	var new_score = current_score + joker_altered_reps * joker_altered_weight;
	var current_scoreLabel = %CurrentScore;
	var initial_score = current_score;
	var duration = 1.0;
	
	#update max score
	max_score = max(max_score, new_score);
	total_score = total_score + joker_altered_reps*joker_altered_weight;
	
	#kill old instances of tweens
	if is_instance_valid(_score_animation_tween):
		_score_animation_tween.kill();
		_score_animation_tween = null;
	
	#access audio player
	var audio_player = %AudioStreamPlayer2D;
	audio_player.stream = load("res://audio/proper_chip1.mp3"); 
	
	#instantiate and run tween
	var tween_obj = create_tween();
	tween_obj.tween_method(func(value):
			current_score = int(value);
			current_scoreLabel.text = str(current_score);
			audio_player.play();
			, initial_score, new_score, duration
			).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD);

	#wait
	await tween_obj.finished;
	
	if is_instance_valid(_score_animation_tween):
		#ensure equal
		current_score = new_score;
		current_scoreLabel.text = str(current_score);
		#clear tween animation queue
		_score_animation_tween.queue_free();
		_score_animation_tween = null;
	

func on_submit(weight: String, reps: String) -> void:
	#if weight.length() > 0 or reps.length() > 0:
	if(weight.length() * reps.length() > 0):
		# Animate
		await animateOnSubmit(int(reps), int(weight));
		
		# Get marketplace if necessary
		await activate_marketplace();
		
		#increase submitted
		submitted = submitted + 1;
		
		# Win condition
		if(current_score >= ante_score):
			await get_tree().create_timer(1).timeout; #timeout for a second so users can see their score
			update_stats();
			await switch_card_focus(); 
		# Lose condition
		elif (((current_score < ante_score) and submitted == 3) && extra_lives == 0):	
			is_playing = false;
			display_loss();
		elif (extra_lives > 0):
			--extra_lives;
			# TODO: Death Joker Animation
			remove_death_joker();
			update_stats();
			await switch_card_focus();
		
		# Enable next button
		enable_next(submitted, current_card_index); #submitted is, at a minimum, 1

func disable_all_buttons(index: int) -> void:
	for i in range(0,3):
		input_weight_array[index][i].editable = false;
		input_rep_array[index][i].editable = false;
		button_array[index][i].disabled = true;

#disables all input buttons in the array except for the exclusion-indexed input buttons
#In the input array and button_array.
#only works per expectations if all buttons are disabled at the start.
func enable_next(exclusion: int, index: int) -> void:
	if(exclusion < 3):
		input_weight_array[index][exclusion].editable = true;
		input_rep_array[index][exclusion].editable = true;
		button_array[index][exclusion].disabled = false;
		
	if(exclusion-1 >= 0):
		input_weight_array[index][exclusion-1].editable = false;
		input_rep_array[index][exclusion-1].editable = false;
		button_array[index][exclusion-1].disabled = true;

func plays_again() -> void:
	set_initial_conditions();

func play_mult_animation(reps: int, weight: int, index: int, color: Color, text: String) -> void:
	var joker_animation_label : Label = card_slot_holder.get_label();
	joker_animation_label.modulate = color;
	joker_animation_label.text = text;
	set_reps_mult_text(str(reps), str(weight)); 
	await card_slot_holder.play_slot_animation(index); 

# 0  : +5 Reps for every exercise (Ronnie Coleman)
# 1  : +5 Weight for leg exercises (Chicken joker muscles)
# 2  : +5 Weight for arm exercises (Hulk Joker)
# 3  : +100 mult on last exercise (Naruto)
# 4  : Extra death allowed (Jacked up Death)
func handle_jokers(reps: int, weight: int) -> Array[int]:
	# Pring Jokers Array
	print("Jokers array being handled: " + str(jokers_array));
	
	var joker_animation_label : Label = card_slot_holder.get_label();
	
	for i in range(0, jokers_array.size()):
		match jokers_array[i]:
			0: 
				reps += 5;
				await play_mult_animation(reps, weight, i, Color.BLUE, "+5 Reps")
				print("Ronnie Coleman: five added to reps")
			1:
				if current_exercise_name == "Squat" or current_exercise_name == "Deadlift":
					weight += 5;
					await play_mult_animation(reps, weight, i, Color.RED, "+5 lbs")
					print("Chicken Joker: five added to weight")
			2:
				if current_exercise_name == "Bench Press":
					weight += 5;
					await play_mult_animation(reps, weight, i, Color.RED, "+5 lbs");
					print("Hulk Joker: five added to weight")
			3:
				# Last Attempt:
				if submitted == 2:
					weight += 100;
					await play_mult_animation(reps, weight, i, Color.RED, "+100 lbs");
					print("Naruto Joker: 100 to weight!")
		
		# Reset text
		joker_animation_label.text = ""; 
			
			
	return [reps, weight];
		

# Activated when the player loses.
# Removes the death joker from one of the slots
# And Sets the next slot to be filled to that slot
func remove_death_joker() -> void:
	joker_to_replace = jokers_array.find(DEATH_JOKER_INDEX) if jokers_array.size() == 1 else 0;
	jokers_array.set(jokers_array.find(DEATH_JOKER_INDEX), -1);
	
	# Update slot with null (-1 as index)
	card_slot_holder.set_joker_slot(joker_to_replace, -1);
		
	--extra_lives;

func add_joker(index: int) -> void:
	# Get current joker
	var replaced_joker = jokers_array.get(joker_to_replace);
	
	# If the death joker is replaced, reduce extra lives by one
	if(replaced_joker == DEATH_JOKER_INDEX):
		--extra_lives;
	
	# Update current joker array
	jokers_array.set(joker_to_replace,index);
	
	# Update image
	card_slot_holder.set_joker_slot(joker_to_replace, index);
	
	# Add extra life if the new index is the death joker:
	extra_lives = extra_lives + 1 if index == DEATH_JOKER_INDEX else extra_lives; 
	
	# Swap joker_to_replace to point to next joker to replace	
	joker_to_replace = 1 - joker_to_replace; 
	
	
		
