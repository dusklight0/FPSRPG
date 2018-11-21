extends "res://Enemy/Enemy.gd"

func _ready():
    _bullet = load("res://Enemy/EnemyBullet.tscn")
    
    
func on_attack_enemy(delta):
    var bullet_instance = _bullet.instance()
    bullet_instance._direction = (_player.global_transform.origin - self.global_transform.origin).normalized()
    
    var t = Transform()
    t.origin = self.global_transform.origin
    t.origin.y = 10
    t = t.looking_at(t.origin + bullet_instance._direction, Vector3(0, 1, 0))
    bullet_instance.set_global_transform(t)
    
    get_tree().root.add_child(bullet_instance)