extends KinematicBody

enum {
    IDLE = 1 << 0, 
    BATTLE = 1 << 1, 
    STOP = 1 << 2, 
    ATTACK = 1 << 3, 
    ATTACKED = 1 << 4, 
    FAINT = 1 << 5, 
    DEAD = 1 << 6
    }

var _room
var _player
var _ui_info

var _hp = 100
var _state = IDLE
var _state_time = 0.0
var _enemy_speed = 12

var _navigation
var _path = []
var _navigation_update_time = 0.0
var _nav_transform = Vector3(0, 0, 0)

var _hit_dir
var _impact_delta = 0.0


func _ready():
    var scene_root = get_tree().root.get_children()[0]
    _player = scene_root._player
    
    _ui_info = $UiInfo
    _ui_info._hp_pos = $HpPos


func bullet_hit(damage, bullet_hit_pos):
    if _hp <= 0:
        return
        
    _hp -= damage
    _ui_info.on_bullet_hit(damage, _hp)
    
    on_change_state(ATTACKED, 0.3)
    
#    var enemy_stop = rand_range(0, 100)
#        if enemy_stop < 20:
#            _stop_time = 1.0
#            _impact_delta = 0.0
#            _hit_dir = (bullet_hit_pos - _player.transform.origin).normalized()
#            _hit_dir.y = 0
#            _enemy_stop_type = 1    
    
    if _hp <= 0:
        on_change_state(DEAD)
    
    
func on_change_state(state, state_time = 0.0):
    if _state == DEAD:
        return
        
    if _state == FAINT:
        if state == ATTACKED:
            _state |= state
            
        else:
            return
            
    _state = state
    _state_time = state_time
    
    
func update_state(delta):
    if _room._player_enter == false:
        on_change_state(IDLE)
        
    elif _state == IDLE and _room._player_enter == true:
        on_change_state(BATTLE)
        
    elif _state == BATTLE or _state == STOP:
        var distance = self.transform.origin.distance_to(_player.transform.origin - _nav_transform)    
        if _state == BATTLE and distance < 50:
            on_change_state(STOP)
        
        else:
            on_change_state(BATTLE)
            
            
func update_attack(delta):
    pass
    
    
func _process(delta):
    update_state(delta)
    if _state == BATTLE or _state == STOP:
        update_attack(delta)
            
    if _state & BATTLE:
        on_battle(delta)
        
    elif _state & ATTACK:
        on_attack(delta)
        
    elif _state & STOP:
        on_stop(delta)
        
    elif _state & DEAD:
        on_dead(delta)
        
    else:
        if _state & ATTACKED:
            on_attecked(delta)
            
        if _state & FAINT:
            on_faint(delta)
    
    
func on_battle(delta):        
    _navigation_update_time += delta
    if _navigation_update_time > 0.5:
        update_path()
        _navigation_update_time = 0
        
    process_movement(delta)
    
    
func on_attecked(delta):
    _state_time -= delta
    
    if _state_time <= 0.0:
        on_change_state(BATTLE)
    
    
func on_attack(delta):    
    attack_enemy(delta)
    
    
func attack_enemy(delta):
    pass


func on_faint(delta):
    pass


func on_stop(delta):
    look_at(_player.transform.origin, Vector3(0, 1, 0))
    

func on_dead(delta):
    if _state == DEAD:
        return
        
    queue_free()    


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
    

func update_path():
    var begin = _navigation.get_closest_point(self.transform.origin)
    var end = _navigation.get_closest_point(_player.transform.origin - _nav_transform)
    var p =_navigation.get_simple_path(begin, end, true)
    _path = Array(p)
    _path.invert()