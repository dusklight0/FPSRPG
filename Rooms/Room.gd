extends Spatial

var _enemy
var _spawn_points

var _navigation
var _doors = []

var _player_enter = false

var _room_info = {
    # U,R,D,L
    door = [0, 0, 0, 0],
    navi_transform = Vector3(0, 0, 0),
    enemy_spawn = false
    }

func _ready():
    _doors = [$DoorU, $DoorR, $DoorD, $DoorL]
    _spawn_points = $SpawnPoints
    _navigation = $Navigation
    _enemy = load("Enemy/EnemyScene.tscn")
    
    $Area.connect("body_entered", self, "collided")
    
    var index = 0
    for v in _room_info.door:
        if v == 0:
            _doors[index].hide()
            var door_collision = _doors[index].get_node("CollisionShape")
            door_collision.disabled = true
            
        index += 1
        
        
func collided(body):
    if _player_enter:
        return
        
    _player_enter = true
    
    if _room_info.enemy_spawn == false:
        return
        
    for spawn_point in _spawn_points.get_children():
        var spawn_point_pos = spawn_point.transform.origin
    
        for v in range(rand_range(spawn_point._min_enemy_count, spawn_point._max_enemy_count)):
            spawn_point_pos.z += rand_range(-5, 5)
            spawn_point_pos.x += rand_range(-10, 10)
    
            var spawn_enemy = _enemy.instance()
            spawn_enemy._navigation = _navigation
            spawn_enemy._nav_transform = _room_info.navi_transform
            spawn_enemy.global_transform.origin = spawn_point_pos
            add_child(spawn_enemy)