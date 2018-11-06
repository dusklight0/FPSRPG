extends Node

var _player
var _enemy = preload("Enemy/EnemyScene.tscn")
var _spawn_point
var _spawn_time = 0
var _spawn_count = 10

var _navigation


func _ready():
    _player = $Player
    _spawn_point = $SpawnPoint
    _navigation = $World/Navigation


func _process(delta):
    if _spawn_count <= 0:
        return
        
    _spawn_time += delta
    if _spawn_time < 0.5:
        return
        
    _spawn_time = 0
    
    var _spawn_point_pos = _spawn_point.transform.origin
    
    _spawn_point_pos.z += rand_range(0, 10)
    _spawn_point_pos.x += rand_range(-50, 50)
    
    var spawn_enemy = _enemy.instance()
    spawn_enemy._player = _player
    spawn_enemy._navigation = _navigation
    add_child(spawn_enemy)
    spawn_enemy.global_translate(_spawn_point_pos)
    
    _spawn_count -= 1