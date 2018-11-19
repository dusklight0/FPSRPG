extends KinematicBody

const GRAVITY = -24.8
const MAX_SPEED = 40
const JUMP_SPEED = 18
const ACCEL= 4.5

const MAX_SPRINT_SPEED = 60
const SPRINT_ACCEL = 20
const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

const WEAPON_NUMBER_TO_NAME = {0:"UNARMED", 1:"MELEE", 2:"BULLET", 3:"RAY"}
const WEAPON_NAME_TO_NUMBER = {"UNARMED":0, "MELEE":1, "BULLET":2, "RAY":3}

# player infos
var _vel = Vector3()
var _dir = Vector3()

var _mouse_sensitivity = 0.1

var _current_weapon_name = "UNARMED"
var _weapons = {"UNARMED":null, "MELEE":null, "BULLET":null, "RAY":null}
var _changing_weapon = false
var _changing_weapon_name = "UNARMED"

var _hp = 100
var _max_hp = 100
var _is_spriting = false

# object ref
var _camera
var _rotation_helper
var _gun_model
var _gun_ray

# ui ref
var _lb_player_status
var _ui_hp_bar

var _game_scene


func _ready():
    _game_scene = get_tree().root.get_children()[0]
    
    _camera = $RotationHelper/Camera
    _rotation_helper = $RotationHelper
    _gun_model = $RotationHelper/Model/BulletGun
    _gun_model.hide()
    
    _gun_ray = $RotationHelper/GunFirePoints/RayFire/RayCast

    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    
    _weapons["MELEE"] = $RotationHelper/GunFirePoints/MeleeFire
    _weapons["BULLET"] = $RotationHelper/GunFirePoints/BulletFire
    _weapons["RAY"] = $RotationHelper/GunFirePoints/RayFire

    var gun_aim_point_pos = $RotationHelper/GunFirePoints.global_transform.origin

    for weapon in _weapons:
        var weapon_node = _weapons[weapon]
        if weapon_node != null:
            weapon_node._player_node = self
            #weapon_node.look_at(gun_aim_point_pos, Vector3(0, 1, 0))
            #weapon_node.rotate_object_local(Vector3(0, 1, 0), deg2rad(180))

    _current_weapon_name = "UNARMED"
    _changing_weapon_name = "UNARMED"

    _lb_player_status = $Hud/Panel/GunLabel
    _ui_hp_bar = $Hud/HpBar
    
    _lb_player_status.text = _current_weapon_name
    
    
func _process(delta):
    process_input(delta)
    process_movement(delta)
    process_changing_weapons(delta)
    

func process_input(delta):
    # Walking
    _dir = Vector3()
    var cam_xform = _camera.global_transform

    var input_movement_vector = Vector2()

    if Input.is_action_pressed("movement_forward"):
        input_movement_vector.y += 1
    if Input.is_action_pressed("movement_backward"):
        input_movement_vector.y -= 1
    if Input.is_action_pressed("movement_left"):
        input_movement_vector.x -= 1
    if Input.is_action_pressed("movement_right"):
        input_movement_vector.x = 1

    input_movement_vector = input_movement_vector.normalized()

    _dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
    _dir += cam_xform.basis.x.normalized() * input_movement_vector.x
    
    # Jumping
#    if is_on_floor():
#        if Input.is_action_just_pressed("movement_jump"):
#            vel.y = JUMP_SPEED
    
    # Sprinting
    _is_spriting = Input.is_action_pressed("movement_sprint")
    
    # Capturing/Freeing the cursor
#    if Input.is_action_just_pressed("ui_cancel"):
#        if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
#            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#        else:
#            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
            
    # Changing weapons.
    var weapon_change_number = WEAPON_NAME_TO_NUMBER[_current_weapon_name]

    if Input.is_key_pressed(KEY_1):
        weapon_change_number = 0
    if Input.is_key_pressed(KEY_2):
        weapon_change_number = 1
    if Input.is_key_pressed(KEY_3):
        weapon_change_number = 2
    if Input.is_key_pressed(KEY_4):
        weapon_change_number = 3

#    if Input.is_action_just_pressed("shift_weapon_positive"):
#        weapon_change_number += 1
#    if Input.is_action_just_pressed("shift_weapon_negative"):
#        weapon_change_number -= 1

    weapon_change_number = clamp(weapon_change_number, 0, WEAPON_NUMBER_TO_NAME.size()-1)

    if _changing_weapon == false:
        if WEAPON_NUMBER_TO_NAME[weapon_change_number] != _current_weapon_name:
            _changing_weapon_name = WEAPON_NUMBER_TO_NAME[weapon_change_number]
            _changing_weapon = true
            
    # Firing the weapons
    if Input.is_action_pressed("fire"):
        if _changing_weapon == false:
            var current_weapon = _weapons[_current_weapon_name]
            if current_weapon != null:
                fire_bullet()
#                if animation_manager.current_state == current_weapon.IDLE_ANIM_NAME:
#                    animation_manager.set_animation(current_weapon.FIRE_ANIM_NAME)

    if Input.is_action_just_pressed("action_use"):
        on_input_use()


func on_input_use():
    _gun_ray.force_raycast_update()
    if false == _gun_ray.is_colliding():
        return
        
    var body = _gun_ray.get_collider()
    if body.has_method("on_action_use"):
        body.on_action_use()


func process_changing_weapons(delta):
    if _changing_weapon == false:
        return

    var weapon_unequipped = false
    var current_weapon = _weapons[_current_weapon_name]

    if current_weapon == null:
        weapon_unequipped = true
    else:
        if current_weapon._is_weapon_enabled == true:
            weapon_unequipped = current_weapon.unequip_weapon()
        else:
            weapon_unequipped = true

    if weapon_unequipped == true:
        var weapon_equiped = false
        var weapon_to_equip = _weapons[_changing_weapon_name]

        if weapon_to_equip == null:
            weapon_equiped = true
        else:
            if weapon_to_equip._is_weapon_enabled == false:
                weapon_equiped = weapon_to_equip.equip_weapon()
            else:
                weapon_equiped = true

        if weapon_equiped == true:
            _changing_weapon = false
            _current_weapon_name = _changing_weapon_name
            _changing_weapon_name = ""
            
            if _current_weapon_name == "BULLET" or _current_weapon_name == "RAY":
                _gun_model.show()
            else:
                _gun_model.hide()
            
            _lb_player_status.text = _current_weapon_name
    

func process_movement(delta):
    _dir.y = 0
    _dir = _dir.normalized()

    _vel.y += delta * GRAVITY

    var hvel = _vel
    hvel.y = 0

    var target = _dir * MAX_SPEED if false == _is_spriting else _dir * MAX_SPRINT_SPEED

    var accel
    if _dir.dot(hvel) > 0:
        if _is_spriting:
            accel = SPRINT_ACCEL
        else:
            accel = ACCEL
    else:
        accel = DEACCEL

    hvel = hvel.linear_interpolate(target, accel * delta)
    _vel.x = hvel.x
    _vel.z = hvel.z
    _vel = move_and_slide(_vel, Vector3(0, 1 ,0), 0.05, 4, deg2rad(40))
    

func _input(event):
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:        
        _rotation_helper.rotate_x(deg2rad(event.relative.y * _mouse_sensitivity))
        self.rotate_y(deg2rad(event.relative.x * _mouse_sensitivity * -1))

        var camera_rot = _rotation_helper.rotation_degrees
        camera_rot.x = clamp(camera_rot.x, -60, 60)
        _rotation_helper.rotation_degrees = camera_rot
        

func fire_bullet():
    if _changing_weapon == true:
        return

    _weapons[_current_weapon_name].fire_weapon()
    
    
func on_attacked(damage, bullet_hit_pos):
    if _hp <= 0:
        return
        
    _hp -= damage
    _ui_hp_bar.rect_size = Vector2(700 * _hp/_max_hp, 20)
    
    if _hp <= 0:
        print('-------- game over')
    