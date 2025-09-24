extends Node2D


func _start_new_game() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
	pass
