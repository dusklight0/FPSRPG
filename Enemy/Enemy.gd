extends KinematicBody

enum EnemyState {
    IDLE = 1 << 0,
    DEAD = 1 << 1,
    FAINT = 1 << 2,
    ATTACKED = 1 << 3,
    CRI_ATTACKED = 1 << 4,
    BATTLE = 1 << 5,
    }
    
enum BattleType {
    BT_WAIT,
    BT_HIDE,
    BT_RUN,
    BT_ATTACK,
    BT_MOVE,
    }

var _room
var _player
var _ui_info

var _hp = 100
var _state = EnemyState.IDLE
var _state_time = 0.0
var _battle_state = BattleType.BT_WAIT
var _battle_state_time = 0.0
var _enemy_speed = 12
var _change_battle_state = false

var _navigation
var _path = []
var _navigation_update_time = 0.0
var _nav_transform = Vector3(0, 0, 0)
var _move_process = false

var _hit_dir
var _hit_mark_anim

const ZERO_VEC = Vector3(0, 0, 0)


func _ready():
    var scene_root = get_tree().root.get_children()[0]
    _player = scene_root._player
    _hit_mark_anim = scene_root.get_node("Hud/HitMark/HitMarkAnim")
    
    _ui_info = $UiInfo
    _ui_info._hp_pos = $HpPos


func bullet_hit(damage, bullet_hit_pos, shape):
    if _hp <= 0:
        return false
        
    _hit_dir = (bullet_hit_pos - _player.transform.origin).normalized()
    _hit_dir.y = 0
    
    var final_damage = damage
    
    if shape <= 0:
        final_damage = damage * 2
        on_change_state(EnemyState.CRI_ATTACKED, 1.0)
    else:
        on_change_state(EnemyState.ATTACKED, 0.3)
        
    on_update_hp(final_damage)
    
    if _hp <= 0:
        on_change_state(EnemyState.DEAD, 1.0)
        
    return true
    
    
func on_update_hp(final_damage):
    _hp -= final_damage
    _ui_info.on_bullet_hit(final_damage, _hp)
    
    _hit_mark_anim.play("Hit")
    
    
func on_change_state(state, state_time = 0.0):        
    if _state == EnemyState.DEAD:
        return
        
    if (_state == EnemyState.FAINT or _state == EnemyState.CRI_ATTACKED or _state == EnemyState.ATTACKED) and \
        (state == EnemyState.FAINT or state == EnemyState.CRI_ATTACKED or state == EnemyState.ATTACKED):
        _state |= state
        
    else:
        _state = state
            
    _state_time = state_time
    
    
func update_state(delta):
    if _room._player_enter == false:
        on_change_state(EnemyState.IDLE)
        
    elif _state == EnemyState.IDLE and _room._player_enter == true:
        on_change_state(EnemyState.BATTLE)

 
func _physics_process(delta):
    update_state(delta)
    
    if _state & EnemyState.DEAD:
        on_dead(delta)
    
    elif _state & EnemyState.BATTLE:
        on_battle(delta)
        
    else:
        if _state & EnemyState.ATTACKED:
            on_attacked(delta)
            
        if _state & EnemyState.CRI_ATTACKED:
            on_cri_attacked(delta)
            
        if _state & EnemyState.FAINT:
            on_faint(delta)
            
    move_process(delta)
    
    
#--------------------- Main State ------------------------

func on_battle(delta):
    match _battle_state:
        BattleType.BT_WAIT:
            on_wait(delta)
            
        BattleType.BT_HIDE:
            on_hide(delta)
            
        BattleType.BT_RUN:
            on_run(delta)
            
        BattleType.BT_ATTACK:
            on_attack(delta)
            
        BattleType.BT_MOVE:
            on_move(delta)
            
    if _change_battle_state == false:
        _battle_state_time += delta
        
    else:
        _change_battle_state = false
        

func on_attacked(delta):
    _state_time -= delta    
    if _state_time <= 0.0:
        on_change_state(EnemyState.BATTLE)
        return false
        
    return true
    
    
func on_cri_attacked(delta):
    _state_time -= delta
    if _state_time <= 0.0:
        on_change_state(EnemyState.BATTLE)
        return false
        
    return true
    
    
func on_faint(delta):
    _state_time -= delta    
    if _state_time <= 0.0:
        on_change_state(EnemyState.BATTLE)
        return false
        
    return true
    
    
func on_dead(delta):
    _state_time -= delta
    if _state_time <= 0.0:
        queue_free()
        return
    
    
#--------------------- Battle State ------------------------    
    
func on_wait(delta):
    pass
    
    
func on_hide(delta):
    pass
    
    
func on_run(delta):
    pass
    
    
func on_move(delta):
    pass
    
    
func on_attack(delta):
    pass
    
    
func on_end_battle_state(states):
    var state_index = int(rand_range(0, len(states)))
    _battle_state = states[state_index]
    _battle_state_time = 0.0
    _change_battle_state = true


#--------------------- Movement ------------------------

func move_process(delta):
    if _move_process == false:
        return
        
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
            
            
#--------------------- Func ------------------------            
            
func get_block_point():
    if _room._block_objects == null:
        return null
        
    var block_objects = _room._block_objects.get_children()
    if block_objects == null:
        return null
        
    var block_point = null
    var distance = 10000
    for v in block_objects:
        var dist = v.transform.origin.distance_to(self.transform.origin)
        if dist < distance:
            distance = dist
            block_point = v.transform.origin
            
    return block_point
    
    
func update_navi_points(begin_point, end_point):
    var begin = _navigation.get_closest_point(begin_point)
    var end = _navigation.get_closest_point(end_point)
    var p =_navigation.get_simple_path(begin, end, true)
    _path = Array(p)
    _path.invert()
