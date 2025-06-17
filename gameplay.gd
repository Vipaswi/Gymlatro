extends Node2D

#declare all variables
@onready var is_playing: bool = true;
var current_score: int;
var ante: int;
var ante_score: int;
var round_count : int;
var display_round: int; #bet. 1 and 3
@onready var max_score: int = 0; 
@onready var total_score: int = 0;

#signal related variables:
@onready var submit_reps: bool = false;

#temp array
var exercise_array: PackedStringArray;
var current_exercise_name : String;

#for disabling and renabling:
var button_array; #an array of size 2 (corresponding ot each card)
var input_weight_array; #an array of size 2  (corresponding ot each card) 
var input_rep_array; #an array of size 2 (corresponding ot each card)
var submitted: int; #a number from 0 to button_array.size() (3) counting submitted rep, weights

#animation variables
var transition_player;
var cards;
var current_card_index: int;
@onready var transition_complete: bool = true;
@onready var _score_animation_tween: Tween = null;
@onready var Card1Control = %Card1Control;
@onready var Card2Control = %Card2Control;
@onready var lose_screen = %YouLoseControl;

#signals for lose conds:
signal set_max_score(max_score: int);
signal set_ante(ante: int);
signal set_round(round_count: int);
signal set_total_score(total_score: int);

#initialize starting conditions
func _ready() -> void:
	set_initial_conditions();

#initial conditions for reusability
func set_initial_conditions() -> void:
	#Initial Variable Conditions
	is_playing = true;
	max_score = 0;
	total_score = 0;
	submit_reps = false;
	transition_complete = true;
	_score_animation_tween = null;
	Card1Control = %Card1Control;
	Card2Control = Card2Control;
	lose_screen = %YouLoseControl;
	
	#hide LoseScene
	lose_screen.visible = false;
	lose_screen.z_index = -1;
	
	#connect signals
	Card1Control.submit_data.connect(on_submit);
	Card2Control.submit_data.connect(on_submit);
	
	#set stage for animationsn and initial positions
	set_animation_properties();
	play_transition("init");
	Card1Control.animation_player.play("RESET");
	Card2Control.animation_player.play("RESET");
	
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

func set_animation_properties() -> void:
	transition_player = %TransitionPlayer; #set the transition.
	cards = [Card1Control.animation_player, Card2Control.animation_player];
	current_card_index = 0; #the first card;

func play_transition(transitionName: String) -> void:
	transition_player.play(transitionName);
	transition_complete = false;
	await transition_player.animation_finished;
	transition_complete = true;
	
func reset_scores() -> void:
	current_score = 0;
	ante = 1;
	ante_score = 200;
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

#is responsible for returning a new random card from the file system
func get_new_random_card() -> void:
	var randomInt = randi() % exercise_array.size();
	current_exercise_name = exercise_array.get(randomInt);
	
	var formatString = "res://images/%s.png";
	
	var imageTexture = load(formatString % current_exercise_name);
	
	var cardDisplay = Card1Control.exercise_texture if current_card_index == 0 else Card2Control.exercise_texture;
	cardDisplay.texture = imageTexture;
	if(!transition_complete):
		await transition_player.animation_finished;
	cards[current_card_index].play("CardFlip"); #Flip the card 

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
	ante_score = ante * 50 + ante_score;
	round_count = round_count + 1; #increase round_count
	ante = ante + (1 if round_count % 3 == 1 and round_count != 1 else 0);
	
	#reset
	current_score = 0;
	submitted = 0;

func switch_card_focus() -> void:
	if(current_card_index == 0):
		Card2Control.animation_player.play("RESET");
		play_transition("animate1");
	else:
		Card1Control.animation_player.play("RESET");
		play_transition("loopcard1");
	
	reset_inputs(); #reset input after animation completion
	current_card_index = (current_card_index - 1) * current_card_index + (current_card_index + 1) * (current_card_index - 1) * -1; #cool formula to make my head hurt more :)
	
#basically our main game logic
func _process(_delta: float) -> void:
	if(is_playing):
		#win condition
		setLabelText();
		

func reset_inputs() -> void:
	for i in range(0, button_array.size()):
		button_array[current_card_index][i].disabled = false;
		button_array[current_card_index][i].add_theme_color_override("white_font", Color(1,1,1,1));
	
	for i in range(0, input_rep_array.size()):
		input_rep_array[current_card_index][i].text = ""; #reset to nothing
		
	for i in range(0, input_weight_array.size()):
		input_weight_array[current_card_index][i].text = ""; #reset to nothing	
		
	disable_all_buttons(current_card_index);
	enable_next(0, current_card_index);

func animateOnSubmit(reps: int, weight: int) -> void:
	#convert for sub anim
	%RepsChips.text = str(reps);
	%WeightMult.text = str(weight);
	
	#play sub anim
	%ScorePlayer.play("NewScore");
	await %ScorePlayer.animation_finished;
	
	#calculate properties of anim
	var new_score = current_score + reps * weight;
	var current_scoreLabel = %CurrentScore;
	var initial_score = current_score;
	var duration = 1.0;
	
	#update max score
	max_score = max(max_score, new_score);
	total_score = total_score + reps*weight;
	
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
		#animate
		await animateOnSubmit(int(reps), int(weight));
		
		#increase submitted
		submitted = submitted + 1;
		
		#win condition
		if(current_score >= ante_score):
			update_stats();
			switch_card_focus();
			get_new_random_card(); 
		#lose condition
		elif ((current_score < ante_score) and submitted == 3):	
			is_playing = false;
			submit_reps = false;
			display_loss();
		
		#Enable next button
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
