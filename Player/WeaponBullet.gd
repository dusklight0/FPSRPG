extends Spatial

const _damage = 15

var _is_weapon_enabled = false
var _player_node = null
var _bullet_scene = preload("PlayerBullet.tscn")
var _fire_pos

func _ready():
    _fire_pos = get_parent().get_parent().get_node("Model/BulletGun/FirePos")
    

func fire_weapon():
    var clone = _bullet_scene.instance()
    var scene_root = get_tree().root.get_children()[0]
    scene_root.add_child(clone)

    clone.global_transform = _fire_pos.global_transform
    clone._bullet_damage = _damage
    clone._direction = _fire_pos.global_transform.basis.z.normalized()
    clone._player = _player_node
    

func equip_weapon():
    _fire_pos = get_parent().get_parent().get_node("Model/BulletGun/FirePos")
    _is_weapon_enabled = true
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
    _is_weapon_enabled = false
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