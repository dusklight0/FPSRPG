extends "res://Enemy/Enemy.gd"

var _bullet
var _attack_time = 0.0
var _action_attacked = false

var _aiming_range = 2.0


func _ready():
    _bullet = load("res://Enemy/EnemyBullet.tscn")
    
    
func on_attacked(delta):
    if .on_attacked(delta) == false:
        return
        
        
func on_cri_attacked(delta):
    if .on_cri_attacked(delta) == false:
        return
        
    if rand_range(0, 100) < 30 and _battle_state != BT_RUN:
        on_end_battle_state([BT_RUN])
        
    
func on_faint(delta):
    if .on_faint(delta) == false:
        return
    
#    move_and_slide(_hit_dir * 40, Vector3(0, 1 ,0), 0.05, 4, deg2rad(40))
#
#    if _impact_delta < 0.07:
#        self.transform.origin.y = lerp(0.0, 1.0, (_impact_delta * 100)/70)
#    else:
#        self.transform.origin.y = lerp(1.0, 0.0, (_impact_delta * 100)/200)
#
#    _impact_delta += delta


func on_wait(delta):
    look_at(_player.transform.origin, Vector3(0, 1, 0))
    
    if _battle_state_time > 1.0:
        on_end_battle_state([BT_HIDE, BT_ATTACK, BT_MOVE])
    
    
func on_hide(delta):
    if _battle_state_time <= 0.0:
        var block_point = get_block_point()           
        if block_point != null:
            var end_point = block_point + ((_player.transform.origin - block_point).normalized() * 10)
            update_navi_points(self.transform.origin, end_point)
        
    _move_process = true
        
    if _battle_state_time > 5.0:
        on_end_battle_state([BT_HIDE, BT_WAIT, BT_MOVE])
        _move_process = false
    
    
func on_run(delta):
    if _battle_state_time <= 0.0:
        var end_point = self.transform.origin + ((_player.transform.origin - self.transform.origin).normalized() * rand_range(30, 100))
        update_navi_points(self.transform.origin, end_point)
        
    _move_process = true
        
    if _battle_state_time > 5.0:
        on_end_battle_state([BT_HIDE, BT_ATTACK])
        _move_process = false
    
    
func on_move(delta):
    _move_process = true
    
    _navigation_update_time += delta
    if _navigation_update_time > 0.5:
        update_navi_points(self.transform.origin, _player.transform.origin - _nav_transform)
        _navigation_update_time = 0
    
    var distance = self.transform.origin.distance_to(_player.transform.origin - _nav_transform)
    if distance <= rand_range(60, 80):
        on_end_battle_state([BT_HIDE, BT_WAIT, BT_ATTACK])
        _move_process = false
    
    
func on_attack(delta):
    if _battle_state_time <= 0.0:
        look_at(_player.transform.origin, Vector3(0, 1, 0))
        
        var target_pos = _player.global_transform.origin
        if rand_range(0, 100) > 30:
            target_pos += Vector3(rand_range(-_aiming_range, _aiming_range), rand_range(-_aiming_range, _aiming_range), rand_range(-_aiming_range, _aiming_range))
            
        var bullet_instance = _bullet.instance()
        bullet_instance._direction = (target_pos - self.global_transform.origin).normalized()
        
        var t = Transform()
        t.origin = self.global_transform.origin
        t.origin.y = 10
        t = t.looking_at(t.origin + bullet_instance._direction, Vector3(0, 1, 0))
        bullet_instance.set_global_transform(t)
        
        get_tree().root.add_child(bullet_instance)
    
    if _battle_state_time > 3.0:
        on_end_battle_state([BT_HIDE, BT_WAIT, BT_MOVE])