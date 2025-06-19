extends Control

@onready var max_score_label = %MaxScoreLabel;
@onready var ante_label = %AnteLabel;
@onready var round_label = %RoundLabel_lose;
@onready var total_lifted_label = %TotalLiftedLabel;

signal is_playing();

func set_max_score(max_score: int):
	max_score_label.text = str(max_score);

func set_ante_label(ante: int):
	ante_label.text = "Ante: " + str(ante);

func set_round_label(round_count: int):
	round_label.text = "Round: " + str(round_count);

func set_total_lifted_label(total_lifted: int):
	total_lifted_label.text = str(total_lifted);

func _on_play_again_button_button_up() -> void:
	emit_signal("is_playing");
