extends StaticBody

var _anim_player
var _opend = false

func _ready():
    _anim_player = $AnimationPlayer


func _on_action_use():
    if _opend:
        return
            
    var scene_root = get_tree().root.get_children()[0]
    var player = scene_root._player
    
    if self.global_transform.origin.distance_to(player.global_transform.origin) > 30.0:
        return
    
    _anim_player.play("OpenBox")
    _opend = true
