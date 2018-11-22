extends "res://Enemy/Enemy.gd"

var _bullet
var _attack_time = 0.0
var _action_attacked = false


func _ready():
    _bullet = load("res://Enemy/EnemyBullet.tscn")
    
    
func on_attecked(delta):
    if .on_attecked(delta) == false:
        return
        
    if _action_attacked == true:
        return
        
    _action_attacked = false
    
    
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


func update_attack(delta):    
    _attack_time += delta
    if _attack_time > rand_range(3.0, 10.0):
        on_change_state(ATTACK, 2.0)
    
    
func on_attack(delta):
    if .on_attack(delta) == false:
        return
        
    if _bullet == null:
        return
        
    if _attack_time <= 0.0:
        return
        
    var bullet_instance = _bullet.instance()
    bullet_instance._direction = (_player.global_transform.origin - self.global_transform.origin).normalized()
    
    var t = Transform()
    t.origin = self.global_transform.origin
    t.origin.y = 10
    t = t.looking_at(t.origin + bullet_instance._direction, Vector3(0, 1, 0))
    bullet_instance.set_global_transform(t)
    
    get_tree().root.add_child(bullet_instance)
    
    _attack_time = 0.0