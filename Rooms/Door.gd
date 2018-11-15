extends StaticBody

var _move_pos


func _ready():
    _move_pos = $MovePos


func on_action_use():
    var scene_root = get_tree().root.get_children()[0]
    var player = scene_root._player
    
    if self.global_transform.origin.distance_to(player.global_transform.origin) > 30.0:
        return

    player.global_transform.origin = _move_pos.global_transform.origin
