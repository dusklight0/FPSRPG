extends "res://Objects/ActionObject.gd"


func on_input_use():
    var game_scene = get_tree().root.get_children()[0]
    var player = game_scene._player
    player.global_transform.origin = _move_pos.global_transform.origin
