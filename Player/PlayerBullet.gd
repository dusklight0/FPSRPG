extends Spatial

var BULLET_SPEED = 90
var BULLET_DAMAGE = 15

const KILL_TIMER = 4
var timer = 0
var hit_something = false
var direction = Vector3()
var _bullet_particle
var _player

func _ready():
    $Area.connect("body_entered", self, "collided")


func _physics_process(delta):
    global_translate(direction * BULLET_SPEED * delta)

    timer += delta
    if timer >= KILL_TIMER:
        queue_free()


func collided(body):
    if hit_something:
        return
        
    if body.has_method("bullet_hit"):
        body.bullet_hit(BULLET_DAMAGE, self.global_transform.origin)

    hit_something = true
    
    var body_name = body.get_name()
    #if body_name.find('Enemy') > 0:
    if _bullet_particle == null:
        _bullet_particle = load("res://Effect/bullet_mark.scn")
    
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