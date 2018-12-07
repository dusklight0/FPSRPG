extends Spatial

const KILL_TIMER = 1

var _player
var _timer = 0
var _effect_speed = 10
var _bezier_point
var _bezier_value = 0
var _max_bezier_value = 0

func _ready():
    pass


func _process(delta):
    if _max_bezier_value <= 0:
        return
    
    var target_pos = (_player.global_transform.origin + (_bezier_point * _bezier_value))
    var direction = (target_pos - self.global_transform.origin).normalized()
    global_translate(direction * _effect_speed * delta)
    
    _bezier_value = lerp(0.0, _max_bezier_value, 1 - (_timer/KILL_TIMER))
    _effect_speed += 2
    
    _timer += delta
    if _timer >= KILL_TIMER:
        queue_free()