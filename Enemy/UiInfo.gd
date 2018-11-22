extends CanvasLayer

var _camera
var _hp_pos

var _hp_bar
var _lb_damage
var _lb_damage_anim

var _hp_visible_time = 0.0


func _ready():
    var scene_root = get_tree().root.get_children()[0]
    var player = scene_root._player
    _camera = player.get_node("RotationHelper/Camera")
    
    _hp_bar = $HpBar
    _lb_damage = $LbDamage
    _lb_damage_anim = $LbDamage/Anim
    
    
func _process(delta):
    if _hp_visible_time <= 0.0:
        return
        
    _hp_visible_time -= delta
    self.transform.origin = _camera.unproject_position(_hp_pos.global_transform.origin)
    
    _hp_bar.show()
    
    if _hp_visible_time <= 0.0:
        _hp_bar.hide()
        
        
func hide_damage_label():
    _lb_damage.hide()
    
    
func on_bullet_hit(damage, hp):
    _lb_damage_anim.stop()
    _lb_damage.text = str(damage)
    _lb_damage.show()
    _lb_damage_anim.play("show")
    
    _hp_bar.value = hp
    _hp_visible_time = 3.0
