extends Spatial

const DAMAGE = 40

var _is_weapon_enabled = false
var _gun_ray
var _player
var _bullet_particle = preload("res://Effect/bullet_mark.scn")
var _soul_effect = preload("res://Effect/SoulEffect.tscn")

var _attack_rate = 0.5
var _last_attack_rate = 0.0

func _ready():
    _gun_ray = $RayCast
    
    
func _physics_process(delta):
    if _last_attack_rate > 0.0:
        _last_attack_rate -= delta
    

func fire_weapon():
    if _last_attack_rate > 0.0:
        return false
        
    _last_attack_rate = _attack_rate
        
    _gun_ray.force_raycast_update()
    if false == _gun_ray.is_colliding():
        return true
        
    var body = _gun_ray.get_collider()
    var shape = _gun_ray.get_collider_shape()
    var hit_point = _gun_ray.get_collision_point()

    if _bullet_particle:
        var particle_node = _bullet_particle.instance()
        get_tree().root.add_child(particle_node)
        particle_node.global_translate(hit_point)
        particle_node.scale = Vector3(2, 2, 2)
        particle_node.set_emitting(true)
        
    if body.has_method("bullet_hit"):
        if body.bullet_hit(DAMAGE, _gun_ray.get_collision_point(), shape):
            show_absorb_effect(shape, hit_point)
            _player.on_hp_absorb(DAMAGE * 0.1)
        
    return true
    
    
func show_absorb_effect(shape, hit_point):
    var distance = _player.global_transform.origin.distance_to(hit_point)
    var soul_effect = _soul_effect.instance()
    get_tree().root.add_child(soul_effect)
    soul_effect._player = _player
    soul_effect._bezier_point = Vector3(0, 1, 0)
    soul_effect._bezier_value = distance / 2.0
    soul_effect._max_bezier_value = soul_effect._bezier_value
    soul_effect._speed_accel = distance / 30.0
    soul_effect.global_translate(hit_point)
        

func equip_weapon():
    _is_weapon_enabled = true
    return true
#	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:
#		is_weapon_enabled = true
#		return true
#
#	if player_node.animation_manager.current_state == "Idle_unarmed":
#		player_node.animation_manager.set_animation("Rifle_equip")
#
#	return false

func unequip_weapon():
    _is_weapon_enabled = false
    return true
#	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:
#		if player_node.animation_manager.current_state != "Rifle_unequip":
#			player_node.animation_manager.set_animation("Rifle_unequip")
#
#	if player_node.animation_manager.current_state == "Idle_unarmed":
#		is_weapon_enabled = false
#		return true
#
#	return false