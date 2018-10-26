extends Spatial

const DAMAGE = 15

var is_weapon_enabled = false
var player_node = null
var bullet_scene = preload("PlayerBullet.tscn")
var fire_pos

func _ready():
    fire_pos = get_parent().get_parent().get_node("Model/BulletGun/FirePos")
    

func fire_weapon():
    var clone = bullet_scene.instance()
    var scene_root = get_tree().root.get_children()[0]
    scene_root.add_child(clone)

    clone.BULLET_DAMAGE = DAMAGE
    clone.global_transform = fire_pos.global_transform
    clone.direction = fire_pos.global_transform.basis.z.normalized()
    

func equip_weapon():
    fire_pos = get_parent().get_parent().get_node("Model/BulletGun/FirePos")
    is_weapon_enabled = true
    return true
#	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:
#		is_weapon_enabled = true
#		return true
#
#	if player_node.animation_manager.current_state == "Idle_unarmed":
#		player_node.animation_manager.set_animation("Pistol_equip")
#
#	return false

func unequip_weapon():
    is_weapon_enabled = false
    return true
#	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:
#		if player_node.animation_manager.current_state != "Pistol_unequip":
#			player_node.animation_manager.set_animation("Pistol_unequip")
#
#	if player_node.animation_manager.current_state == "Idle_unarmed":
#		is_weapon_enabled = false
#		return true
#	else:
#		return false