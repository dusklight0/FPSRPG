extends StaticBody


func _on_action_use():
    var scene_root = get_tree().root.get_children()[0]
    var player = scene_root._player
    
    if self.global_transform.origin.distance_to(player.global_transform.origin) > 30.0:
        return
    
    var direction = player.global_transform.origin - self.global_transform.origin
    direction = direction.normalized()
    
    var move_pos = self.global_transform.origin
    move_pos.y = 0
    if direction.z < 0:
        move_pos.z = move_pos.z + 20
    else:
        move_pos.z = move_pos.z - 20
    
    player.global_transform.origin = move_pos
