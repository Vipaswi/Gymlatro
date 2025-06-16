extends Node2D

#declare all variables
var isPlaying: bool;
var currentScore: int;
var ante: int;
var anteScore: int;
var roundCount : int;
var displayRound: int; #bet. 1 and 3

#signal related variables:
var submitReps: bool;

#temp array
var exerciseArray: PackedStringArray;
var currentExerciseName : String;

#for disabling and renabling:
var buttonArray; #an array of size 2 (corresponding ot each card)
var inputWeightArray; #an array of size 2  (corresponding ot each card) 
var inputRepArray; #an array of size 2 (corresponding ot each card)
var submitted: int; #a number from 0 to buttonArray.size() (3) counting submitted rep, weights

#animation variables
var transitionPlayer;
var cards;
var currentCardIndex: int;

@onready var Card1Control = %Card1Control;
@onready var Card2Control = %Card2Control;

#initialize starting conditions
func _ready() -> void:
	submitReps = false;
	isPlaying = true;
	setAnimationProperties();
	setButtonArray();
	disableAllButtons(0);
	disableAllButtons(1);
	enableNext(0, 0); 
	enableNext(0, 1); 
	resetScores();
	getExercises();
	getNewRandomCard();

func setAnimationProperties() -> void:
	transitionPlayer = %TransitionPlayer; #set the transition.
	cards = [%Card1Control.get_node("AnimationPlayer"), %Card2Control.get_node("AnimationPlayer")];
	currentCardIndex = 0; #the first card;

func playTransition(transitionName: String) -> void:
	transitionPlayer.play(transitionName);
	await transitionPlayer.animation_finished;
	
func resetScores() -> void:
	currentScore = 0;
	ante = 1;
	anteScore = 200;
	submitted = 0;
	roundCount = 1;
	

#displays the try info
func displayLoss() -> void:
	pass;
	
#Gets the exercises from the text file
func getExercises() -> void:
	var file = FileAccess.open("res://exercises/fiveExerciseList.txt", FileAccess.READ);
	var exerciseString = file.get_as_text();
	if(exerciseString.length() <= 0):
		push_error("No exercises to read from");
	exerciseArray = exerciseString.split("\n", false);

#is responsible for returning a new random card from the file system
func getNewRandomCard() -> void:
	var randomInt = randi() % exerciseArray.size();
	currentExerciseName = exerciseArray.get(randomInt);
	
	var formatString = "res://images/%s.png";
	
	var imageTexture = load(formatString % currentExerciseName);
	
	var cardDisplay = Card1Control.exercise_texture if currentCardIndex == 0 else Card2Control.exercise_texture;
	cardDisplay.texture = imageTexture;
	cards[currentCardIndex].play("CardFlip"); #Flip the card 
	await cards[currentCardIndex].animation_finished;

#Sets the text for all the labels based on game state
func setLabelText() -> void:
	var userScore = %Label4;
	userScore.text = str(anteScore);
	
	var anteCount = %Label6;
	anteCount.text = str(ante);
	
	#set labels for both
	var exerciseLabel = Card1Control.exercise_label;
	exerciseLabel.text = currentExerciseName;
	
	var exerciseLabel2 = Card2Control.exercise_label;
	exerciseLabel2.text = currentExerciseName;
	
	var currentScoreLabel = %CurrentScore;
	currentScoreLabel.text = str(currentScore);
	
	var roundLabel = %RoundLabel;
	roundLabel.text = str(roundCount);
	
func setButtonArray() -> void:
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
	buttonArray = [
		[buttonSubmit1, buttonSubmit2, buttonSubmit3],
		[buttonSubmit1_2, buttonSubmit2_2, buttonSubmit3_2]
	]
	
	inputWeightArray = [
		[weightWrite1, weightWrite2, weightWrite3],
		[weightWrite1_2, weightWrite2_2, weightWrite3_2]
	]
	
	inputRepArray = [
		[repWrite1, repWrite2, repWrite3],
		[repWrite1_2, repWrite2_2, repWrite3_2]
	]

func updateStats() -> void:
	anteScore = ante * 50 + anteScore;
	roundCount = roundCount + 1; #increase roundCount
	ante = ante + roundCount/3; #for every three rounds inc. ante
	currentScore = 0;
	submitted = 0;

func switchCardFocus() -> void:
	if(currentCardIndex == 0):
		playTransition("animate1");
	else:
		playTransition("loopCard1");
		playTransition("init");
	
	resetInputs(); #reset input after animation completion
	currentCardIndex = (currentCardIndex - 1) * currentCardIndex + (currentCardIndex + 1) * (currentCardIndex - 1) * -1; #cool formula to make my head hurt more :)
	
#basically our main game logic
func _process(_delta: float) -> void:
	if(isPlaying):
		#win condition
		setLabelText();
		if(submitReps and (currentScore >= anteScore)):
			updateStats();
			switchCardFocus();
			getNewRandomCard(); #display new card
		elif (submitReps and !(currentScore <= anteScore) and submitted == 3):	
			isPlaying = false;
			submitReps = false;
			displayLoss();

func resetInputs() -> void:
	for i in range(0, buttonArray.size()):
		buttonArray[currentCardIndex][i].disabled = false;
		buttonArray[currentCardIndex][i].add_theme_color_override("white_font", Color(1,1,1,1));
	
	for i in range(0, inputRepArray.size()):
		inputRepArray[currentCardIndex][i].text = ""; #reset to nothing
		
	for i in range(0, inputWeightArray.size()):
		inputWeightArray[currentCardIndex][i].text = ""; #reset to nothing	
		
	disableAllButtons(currentCardIndex);
	enableNext(0, currentCardIndex);

func on_submit(_button: Button, weight: String, reps: String) -> void:
	#if weight.length() > 0 or reps.length() > 0:
	if(weight.length() * reps.length() > 0):
		var weightInt = int(weight);
		var repsInt = int(reps);
		#TODO: Add animation for incrementing weight and repsInt
		currentScore += weightInt * repsInt;
		setLabelText();
		submitReps = true;
		submitted = submitted + 1; #increase submitted
		enableNext(submitted, currentCardIndex); #submitted is, at a minimum, 1

func disableAllButtons(index: int) -> void:
	for i in range(0,3):
		inputWeightArray[index][i].editable = false;
		inputRepArray[index][i].editable = false;
		buttonArray[index][i].disabled = true;

#disables all input buttons in the array except for the exclusion-indexed input buttons
#In the input array and buttonArray.
#only works per expectations if all buttons are disabled at the start.
func enableNext(exclusion: int, index: int) -> void:
	if(exclusion < 3):
		inputWeightArray[index][exclusion].editable = true;
		inputRepArray[index][exclusion].editable = true;
		buttonArray[index][exclusion].disabled = false;
		
	if(exclusion-1 >= 0):
		inputWeightArray[index][exclusion-1].editable = false;
		inputRepArray[index][exclusion-1].editable = false;
		buttonArray[index][exclusion-1].disabled = true;

func _on_button_submit_1_button_up() -> void:
	var button = %ButtonSubmit1;
	var reps = %RepWrite1;
	var weight = %WeightWrite1;
	print("submitted button 1 Card 1");
	on_submit(button, reps.text, weight.text);


func _on_button_submit_2_button_up() -> void:
	var button = %ButtonSubmit2;
	var reps = %RepWrite2;
	var weight = %WeightWrite2;
	on_submit(button, reps.text, weight.text);# Replace with function body.


func _on_button_submit_3_button_up() -> void:
	var button = %ButtonSubmit3;
	var reps = %RepWrite3;
	var weight = %WeightWrite3;
	on_submit(button, reps.text, weight.text);# Replace with function body.



func _on__button_submit_3_button_up_2() -> void:
	var button = %ButtonSubmit3_2;
	var reps = %RepWrite3_2;
	var weight = %WeightWrite3_2;
	on_submit(button, reps.text, weight.text);


func _on__button_submit_2_button_up_2() -> void:
	var button = %ButtonSubmit2_2;
	var reps = %RepWrite2_2;
	var weight = %WeightWrite2_2;
	on_submit(button, reps.text, weight.text);


func _on__button_submit_1_button_up_2() -> void:
	var button = %ButtonSubmit1_2;
	var reps = %RepWrite1_2;
	var weight = %WeightWrite1_2;
	on_submit(button, reps.text, weight.text);
