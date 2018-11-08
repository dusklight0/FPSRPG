extends Spatial

const KILL_TIMER = 4

var _bullet_speed = 120
var _bullet_damage = 5

var _timer = 0
var _hit_something = false
var _direction = Vector3()

func _ready():
    $Area.connect("body_entered", self, "collided")


func _physics_process(delta):
    global_translate(_direction * _bullet_speed * delta)

    _timer += delta
    if _timer >= KILL_TIMER:
        queue_free()


func collided(body):
    if _hit_something:
        return
        
    var body_name = body.get_name()
    if body_name.find("Enemy") > 0:
        return
        
    if body.has_method("_on_attacked"):
        body._on_attacked(_bullet_damage, self.global_transform.origin)
        
    _hit_something = true
    
    queue_free()