extends Spatial

const DAMAGE = 15

var is_weapon_enabled = false
var player_node = null
var bullet_scene = preload("Player/PlayerBullet.tscn")

func _ready():
    pass

func fire_weapon():
    var clone = bullet_scene.instance()
    var scene_root = get_tree().root.get_children()[0]
    scene_root.add_child(clone)

    clone.global_transform = self.global_transform
    clone.scale = Vector3(4, 4, 4)
    clone.BULLET_DAMAGE = DAMAGE

func equip_weapon():
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