extends KinematicBody

var _room
var _player
var _enemy_speed = 12
var _hp_bar
var _hp = 100
var _max_hp = 100

var _stop_time = 0.0

var _bullet
var _attack_time = 0.0
var _attack_stop_time = 0.0
var _enemy_stop_type = 0

var _destroy = false

var _navigation
var _path = []
var _navigation_update_time = 0.0
var _nav_transform = Vector3(0, 0, 0)

var _hit_dir
var _impact_delta = 0.0

func _ready():
    var scene_root = get_tree().root.get_children()[0]
    _player = scene_root._player
    _hp_bar = $RotationHelper/Model/HpBar
    
    
func impact_enemy(delta):
    move_and_slide(_hit_dir * 40, Vector3(0, 1 ,0), 0.05, 4, deg2rad(40))
    
    if _impact_delta < 0.07:
        self.transform.origin.y = lerp(0.0, 1.0, (_impact_delta * 100)/70)
    else:
        self.transform.origin.y = lerp(1.0, 0.0, (_impact_delta * 100)/200)
        
    _impact_delta += delta


func bullet_hit(damage, bullet_hit_pos):
    if _hp <= 0:
        return
        
    _hp -= damage
    _hp_bar.region_rect = Rect2(0, 0, 500 * _hp/_max_hp, 40)
    
    if _stop_time <= 0.0:
        _stop_time = 1.0
        _enemy_stop_type = 0
    else:
        var enemy_stop = rand_range(0, 100)
        if enemy_stop < 20:
            _stop_time = 1.0
            _impact_delta = 0.0
            _hit_dir = (bullet_hit_pos - _player.transform.origin).normalized()
            _hit_dir.y = 0
            _enemy_stop_type = 1        
    
    if _hp <= 0:        
        destroy_enemy()
    
    
func destroy_enemy():
    _destroy = true
    queue_free()    
    
    
func update_path():
    var begin = _navigation.get_closest_point(self.transform.origin)
    var end = _navigation.get_closest_point(_player.transform.origin - _nav_transform)
    var p =_navigation.get_simple_path(begin, end, true)
    _path = Array(p)
    _path.invert()
    
    
func _process(delta):
    if _destroy:
        return
        
    if _room._player_enter == false:
        return
        
    if _stop_time > 0.0:
        if _enemy_stop_type == 1:
            impact_enemy(delta)
        _stop_time -= delta
        return
        
    attack_enemy(delta)

    if _attack_stop_time > 0.0:
        _attack_stop_time -= delta
        return
        
    var distance = self.transform.origin.distance_to(_player.transform.origin - _nav_transform)    
    if distance < 50:
        lookat_player()
        return
        
    _navigation_update_time += delta
    if _navigation_update_time > 0.5:
        update_path()
        _navigation_update_time = 0
        
    process_movement(delta)
    
    
func lookat_player():
    look_at(_player.transform.origin, Vector3(0, 1, 0))
    
    
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
        
        move_and_slide(atdir * _enemy_speed, Vector3(0, 1 ,0), 0.05, 4, deg2rad(40))

        if _path.size() < 2:
            _path = []
    
    
func attack_enemy(delta):
    if _destroy:
        return
        
    if _bullet == null:
        return
        
    if _attack_stop_time > 0.0:
        return
        
    _attack_time += delta
    if _attack_time < rand_range(2, 5):
        return
        
    _attack_stop_time = 1.5
    _attack_time = 0
    
    on_attack_enemy(delta)
    
    
func on_attack_enemy(delta):
    pass