extends Spatial

const KILL_TIMER = 4

var _bullet_speed = 160
var _bullet_damage = 20

var _timer = 0
var _hit_something = false
var _direction = Vector3()

func _ready():
    $Area.connect("body_entered", self, "collided")


func _process(delta):
    global_translate(_direction * _bullet_speed * delta)

    _timer += delta
    if _timer >= KILL_TIMER:
        queue_free()


func collided(body):
    if _hit_something:
        return
          
    if body.has_method("on_attacked"):
        body.on_attacked(_bullet_damage, self.global_transform.origin)
        
    _hit_something = true
    
    queue_free()