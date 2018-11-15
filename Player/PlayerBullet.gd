extends Spatial

const KILL_TIMER = 4

var _bullet_speed = 90
var _bullet_damage = 15

var _timer = 0
var _hit_something = false
var _direction = Vector3()
var _bullet_particle
var _player

func _ready():
    _bullet_particle = load("res://Effect/bullet_mark.scn")
    $Area.connect("body_entered", self, "collided")


func _process(delta):
    global_translate(_direction * _bullet_speed * delta)

    _timer += delta
    if _timer >= KILL_TIMER:
        queue_free()


func collided(body):
    if _hit_something:
        return
        
    if body.has_method("bullet_hit"):
        body.bullet_hit(_bullet_damage, self.global_transform.origin)

    _hit_something = true
    
    #var body_name = body.get_name()
    
    #if _bullet_particle:
        #var particle_node = _bullet_particle.instance()
        #get_tree().root.add_child(particle_node)
        
#        var t = Transform()
#        t.origin = self.transform.origin
#        t = t.looking_at(self.transform.origin + atdir, Vector3(0, 1, 0))
#        particle_node.set_transform(t)
        
        #particle_node.global_translate(self.global_transform.origin)
        #particle_node.global_transform = self.global_transform
        #particle_node.look_at(_player.transform.origin, Vector3(0, 1, 0))
        #particle_node.rotate(Vector3(0, 1, 0), deg2rad(180))
        #particle_node.restart()
    
    queue_free()