extends KinematicBody

var _player
var _enemy_speed = 12
var _hp_bar
var _hp = 100
var _max_hp = 100

var _bullet = preload("EnemyBullet.tscn")
var _bullet_time = 0

var _destroy = false

var _navigation
var _path = []
var _navigation_update_time = 0.0
var _nav_transform = Vector3(0, 0, 0)

func _ready():
    var scene_root = get_tree().root.get_children()[0]
    _player = scene_root._player
    _hp_bar = $RotationHelper/Model/HpBar


func bullet_hit(damage, bullet_hit_pos):
    if _hp <= 0:
        return
        
    _hp -= damage
    _hp_bar.region_rect = Rect2(0, 0, 500 * _hp/_max_hp, 40)
    
    if _hp <= 0:        
        destroy_enemy()
    
    
func destroy_enemy():
    _destroy = true
    queue_free()
    

func _process(delta):
    _attack_enemy(delta)
    
    
func _update_path():
    var begin = _navigation.get_closest_point(self.transform.origin)
    var end = _navigation.get_closest_point(_player.transform.origin - _nav_transform)
    var p =_navigation.get_simple_path(begin, end, true)
    _path = Array(p)
    _path.invert()
    
    
func _physics_process(delta):
    if _destroy:
        return
        
    _navigation_update_time += delta
    if _navigation_update_time > 0.1:
        _update_path()
        _navigation_update_time = 0
        
    process_movement(delta)
    
    
func process_movement(delta):
    if _path.size() > 1:
        var to_walk = delta * _enemy_speed
        var to_watch = Vector3(0, 1, 0)
        while to_walk > 0 and _path.size() >= 2:
            var pfrom = _path[_path.size() - 1]
            var pto = _path[_path.size() - 2]
            to_watch = (pto - pfrom).normalized()
            var d = pfrom.distance_to(pto)
            if d <= to_walk:
                _path.remove(_path.size() - 1)
                to_walk -= d
            else:
                _path[_path.size() - 1] = pfrom.linear_interpolate(pto, to_walk/d)
                to_walk = 0

        var atpos = _path[_path.size() - 1]
        var atdir = to_watch
        atdir.y = 0

        var t = Transform()
        t.origin = self.transform.origin
        t = t.looking_at(self.transform.origin + atdir, Vector3(0, 1, 0))
        self.set_transform(t)
        
        move_and_slide(atdir * _enemy_speed, Vector3(0,1,0), false, 4, deg2rad(40))

        if _path.size() < 2:
            _path = []
    
    
func _attack_enemy(delta):
    if _destroy:
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