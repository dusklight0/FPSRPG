extends Spatial

const DAMAGE = 4

var _is_weapon_enabled = false
var _player_node = null
var _gun_ray
var _bullet_particle

func _ready():
    _gun_ray = $RayCast
    

func fire_weapon():
    _gun_ray.force_raycast_update()
    if false == _gun_ray.is_colliding():
        return
        
    var body = _gun_ray.get_collider()    
    if body == _player_node:
        return
        
    var collision_point = _gun_ray.get_collision_point()        

    if _bullet_particle:
        var particle_node = _bullet_particle.instance()
        get_tree().root.add_child(particle_node)
        particle_node.global_translate(collision_point)
        particle_node.restart()
        
    if body.has_method("bullet_hit"):
        body.bullet_hit(DAMAGE, _gun_ray.get_collision_point())
        

func equip_weapon():
    _is_weapon_enabled = true
    _bullet_particle = load("res://Effect/bullet_mark.scn")
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