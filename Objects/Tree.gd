extends StaticBody

var _on_enter = false

func on_action_use():
    if _on_enter:
        return
        
    _on_enter = true
    
    var game_scene = get_tree().root.get_children()[0]
    game_scene.change_scene("res://Rooms/Dungeon.tscn")