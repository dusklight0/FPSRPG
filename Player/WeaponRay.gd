extends Spatial

const DAMAGE = 4

var is_weapon_enabled = false
var player_node = null
var gun_ray

func _ready():
    gun_ray = $RayCast
    

func fire_weapon():
    gun_ray.force_raycast_update()
    if false == gun_ray.is_colliding():
        return
        
    var body = gun_ray.get_collider()
    if body == player_node:
        pass
    elif body.has_method("bullet_hit"):
        body.bullet_hit(DAMAGE, gun_ray.get_collision_point())
        

func equip_weapon():
    is_weapon_enabled = true
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
    is_weapon_enabled = false
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