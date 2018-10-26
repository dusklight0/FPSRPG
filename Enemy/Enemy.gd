extends KinematicBody

var _player
var _enemy_speed = 0.2
var _hp_bar
var _hp = 500
var _max_hp = 500

var _bullet = preload("EnemyBullet.tscn")
var _bullet_time = 0

var destroy = false

func _ready():
    _hp_bar = $RotationHelper/Model/HpBar


func bullet_hit(damage, bullet_hit_pos):
    if _hp <= 0:
        return
        
    _hp -= damage
    _hp_bar.region_rect = Rect2(0, 0, 500 * _hp/_max_hp, 40)
    
    if _hp <= 0:        
        destroy_enemy()
    
    
func set_player(player):
    _player = player
    
    
func destroy_enemy():
    destroy = true
    _bullet = null 
    _player = null
    queue_free()
    

func _process(delta):
    _attack_enemy(delta)
    
    
func _physics_process(delta):
    process_movement(delta)     
    
    
func process_movement(delta):
    if destroy:
        return
        
    var dir = _player.global_transform.origin - global_transform.origin
    dir.y = 0

    move_and_slide(dir * 3 * delta, Vector3(0,1,0), 0.05, 4, deg2rad(40))    
    look_at(_player.global_transform.origin, Vector3(0, 1, 0))
    
    
func _attack_enemy(delta):
    if destroy:
        return
        
    if _bullet == null:
        return
        
    _bullet_time += delta
    if _bullet_time < 5:
        return
        
    _bullet_time = 0
    
#    var bullet_instance = _bullet.instance()
#    get_parent().add_child(bullet_instance)
#    bullet_instance.global_translate(get_global_transform().origin)
#    var bullet_target_pos = _player.get_global_transform().origin
#    bullet_instance.look_at(bullet_target_pos, Vector3(0, 1, 0)) 
#    bullet_instance._init_bullet(bullet_target_pos)