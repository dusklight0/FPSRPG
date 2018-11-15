extends Node

var _player


func _ready():
    _player = $Player
    _player.global_transform.origin = Vector3(0, 0, -60)
    
    make_home()
    
    
func make_home():
    var home = load("res://Rooms/Home.tscn")
    var home_instance = home.instance()
    add_child(home_instance)
    
# U,R,D,L
func make_dungeon():
    make_room("res://Rooms/StartRoom.tscn", [1, 0, 0, 0], false, Vector3(0, 0, 0))
    make_room("res://Rooms/Room1.tscn", [0, 0, 1, 1], true, Vector3(0, 0, 210))
    make_room("res://Rooms/Room1.tscn", [0, 1, 0, 0], true, Vector3(210, 0, 210))
    
    
func make_room(room_name, door_info, enemy_spawn, room_pos):
    var room = load(room_name)
    var room_instance = room.instance()
    room_instance._room_info.door = door_info
    room_instance._room_info.enemy_spawn = enemy_spawn
    room_instance._room_info.navi_transform = room_pos
    room_instance.global_transform.origin = (room_pos)
    add_child(room_instance)