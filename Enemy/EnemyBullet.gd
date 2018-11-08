extends Spatial

const KILL_TIMER = 4

var _bullet_speed = 70
var _bullet_damage = 15

var _timer = 0
var _hit_something = false

func _ready():
    $Area.connect("body_entered", self, "collided")


func _physics_process(delta):
    var forward_dir = global_transform.basis.z.normalized()
    global_translate(forward_dir * _bullet_speed * delta)

    _timer += delta
    if _timer >= KILL_TIMER:
        queue_free()


func collided(body):
    if _hit_something == false:
        if body.has_method("bullet_hit"):
            body.bullet_hit(BULLET_DAMAGE, self.global_transform.origin)

    _hit_something = true
    queue_free()