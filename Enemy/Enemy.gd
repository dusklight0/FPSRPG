extends KinematicBody

enum {
    IDLE = 1 << 0, 
    BATTLE = 1 << 1, 
    STOP = 1 << 2, 
    ATTACK = 1 << 3, 
    ATTACKED = 1 << 4, 
    FAINT = 1 << 5, 
    DEAD = 1 << 6,
    DESTROY = 1 << 7,
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
var _hit_mark_anim


func _ready():
    var scene_root = get_tree().root.get_children()[0]
    _player = scene_root._player
    _hit_mark_anim = scene_root.get_node("Hud/HitMark/HitMarkAnim")
    
    _ui_info = $UiInfo
    _ui_info._hp_pos = $HpPos


func bullet_hit(damage, bullet_hit_pos, shape):
    if _hp <= 0:
        return
        
    _hit_dir = (bullet_hit_pos - _player.transform.origin).normalized()
    _hit_dir.y = 0
    
    var final_damage = damage
    
    if shape <= 0:
        final_damage = damage * 2
        on_change_state(FAINT, 3.0)
    else:
        on_change_state(ATTACKED, 0.3)
        
    _hp -= final_damage
    _ui_info.on_bullet_hit(final_damage, _hp)
    
    _hit_mark_anim.play("Hit")
    
    if _hp <= 0:
        on_change_state(DEAD, 1.0)
    
    
func on_change_state(state, state_time = 0.0):
    return
    
    if _state == DESTROY:
        return
        
    if state != DEAD and state != DESTROY:
        if _state == FAINT and _state_time > 0.0:
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
            
            
# diside attack way
func update_attack(delta):
    pass
    
    
func _physics_process(delta):
    if _state == DESTROY:
        return
    
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
        return false
        
    return true
    
    
func on_attack(delta):    
    _state_time -= delta    
    if _state_time <= 0.0:
        on_change_state(BATTLE)
        return false
        
    return true


func on_faint(delta):
    _state_time -= delta    
    if _state_time <= 0.0:
        on_change_state(BATTLE)
        return false
        
    return true


func on_stop(delta):
    look_at(_player.transform.origin, Vector3(0, 1, 0))
    

func on_dead(delta):
    _state_time -= delta
    if _state_time <= 0.0:
        on_change_state(DESTROY)
        on_destroy()
        return
        
        
func on_destroy():
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