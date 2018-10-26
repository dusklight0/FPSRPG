extends RigidBody


func _ready():
    pass
    

func bullet_hit(damage, bullet_hit_pos):
    print('----------> hit!')
    var direction_vect = global_transform.origin - bullet_hit_pos
    direction_vect = direction_vect.normalized()

    apply_impulse(bullet_hit_pos, direction_vect * damage)
