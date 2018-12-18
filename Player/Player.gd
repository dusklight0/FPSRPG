extends KinematicBody

const GRAVITY = -24.8
const MAX_SPEED = 80
const ACCEL= 4.5

const MAX_STEP_SPEED = 150
const STEP_ACCEL = 150
const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

# player infos
var _vel = Vector3()
var _dir = Vector3()

var _mouse_sensitivity = 0.1

var _hp = 100
var _max_hp = 100
var _step_time = 0.0
var _is_step = false

# object ref
var _camera
var _rotation_helper
var _gun
var _gun_anim
var _gun_ray
var _ani_player

# ui ref
var _ui_hp_bar
var _ui_shield_bar
var _game_scene


func _ready():
    _game_scene = get_tree().root.get_children()[0]
    
    _camera = $RotationHelper/Camera
    _rotation_helper = $RotationHelper
    _gun_anim = $RotationHelper/Model/RHand/AnimationPlayer
    
    _gun_ray = $RotationHelper/GunFirePoints/RayFire/RayCast
    
    var weapon_ray = $RotationHelper/GunFirePoints/RayFire
    weapon_ray._player = self

    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    
    #_weapons["MELEE"] = $RotationHelper/GunFirePoints/MeleeFire
    #_weapons["BULLET"] = $RotationHelper/GunFirePoints/BulletFire
    _gun = $RotationHelper/GunFirePoints/RayFire

    var gun_aim_point_pos = $RotationHelper/GunFirePoints.global_transform.origin
    
    _ui_hp_bar = _game_scene.get_node("Hud/HpBar")
    _ui_shield_bar = _game_scene.get_node("Hud/ShieldBar")
    
    #_ani_player = $"RotationHelper/Model/AnimationPlayer"
    #_ani_player.play("Equip")
    
    
func _physics_process(delta):
    process_input(delta)
    process_movement(delta)
    

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
    
    if _step_time <= 0.0 and Input.is_action_just_pressed("movement_step"):
        _step_time = 1.0
        _is_step = true
        
    else:
        _step_time -= delta
    
    # Capturing/Freeing the cursor
#    if Input.is_action_just_pressed("ui_cancel"):
#        if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
#            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#        else:
#            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
            
    # Firing the weapons
    if Input.is_action_pressed("fire"):
        fire_bullet()
    

func process_movement(delta):
    _dir.y = 0
    _dir = _dir.normalized()

    _vel.y += delta * GRAVITY

    var hvel = _vel
    hvel.y = 0

    var target = _dir * MAX_SPEED if _is_step == false else _dir * MAX_STEP_SPEED

    var accel
    if _dir.dot(hvel) > 0:
        if _is_step == true:
            accel = STEP_ACCEL
        else:
            accel = ACCEL
    else:
        accel = DEACCEL

    hvel = hvel.linear_interpolate(target, accel * delta)
    _vel.x = hvel.x
    _vel.z = hvel.z
    _vel = move_and_slide(_vel, Vector3(0, 1 ,0), 0.05, 4, deg2rad(40))
    
    _is_step = false
    

func _input(event):
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:        
        _rotation_helper.rotate_x(deg2rad(event.relative.y * _mouse_sensitivity))
        self.rotate_y(deg2rad(event.relative.x * _mouse_sensitivity * -1))

        var camera_rot = _rotation_helper.rotation_degrees
        camera_rot.x = clamp(camera_rot.x, -60, 60)
        _rotation_helper.rotation_degrees = camera_rot
        

func fire_bullet():
    if _gun.fire_weapon():
        pass
        #_ani_player.play("Shoot")
        
        
func update_hp_ui():
    _ui_hp_bar.value = _hp
    if _hp > _max_hp:
        _ui_shield_bar.value = _hp - _max_hp
        _ui_shield_bar.show()
    else:
        _ui_shield_bar.hide()
        
        
func on_hp_absorb(damage):
    _hp += damage
    update_hp_ui()
    
    
func on_attacked(damage, bullet_hit_pos):
    if _hp <= 0:
        return
    
    _hp -= damage
    update_hp_ui()
    
    if _hp <= 0:
        print('-------- game over')
    