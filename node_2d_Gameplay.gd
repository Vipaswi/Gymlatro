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

#initialize starting conditions
func ready() -> void:
	submitReps = false;
	isPlaying = false;
	currentScore = 0;
	ante = 1;
	anteScore = 200;
	
	#GetButtons
	var branch_sceneA = $Node2D;  # or however you access it
	var controlScene = branch_sceneA.get_node("Control");  # adjust path as needed
	var buttonScene = controlScene.get_node("Button");
	buttonScene.pressed.connect(_on_play_button_pressed);
	
#displays the try info
func displayLoss() -> void:
	pass;

#is responsible for returning a new random card from the file system
func getNewRandomCard() -> void:
	pass;

#basically our main game logic
func _process(_delta: float) -> void:
	if(isPlaying):
		#win condition
		if(submitReps and (currentScore >= anteScore)):
			anteScore = ante * 50 + anteScore;
			roundCount = roundCount + 1; #increase roundCount
			ante = ante + roundCount/3; #for every three rounds inc. ante
			currentScore = 0;
			getNewRandomCard(); #display new card
		elif (submitReps and !(currentScore <= anteScore)):	
			isPlaying = false;
			displayLoss();
			

#playButton
func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("SubViewportContainer/SubViewport/Node2d")
	print("clikced button")
	
