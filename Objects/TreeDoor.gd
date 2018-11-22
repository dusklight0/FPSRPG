extends "res://Objects/ActionObject.gd"


func on_input_use():    
    var game_scene = get_tree().root.get_children()[0]
    game_scene.change_scene("res://Rooms/Dungeon.tscn")