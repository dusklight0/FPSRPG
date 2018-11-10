extends Node

var _player


func _ready():
    # U,R,D,L
    _make_room("Rooms/StartRoom.tscn", [1, 0, 0, 0], false, Vector3(0, 0, 0))
    _make_room("Rooms/Room1.tscn", [0, 0, 1, 1], true, Vector3(0, 0, 210))
    _make_room("Rooms/Room1.tscn", [0, 1, 0, 0], true, Vector3(210, 0, 210))
    
    _player = $Player
    _player.global_transform.origin = Vector3(0, 0, 0)
    
    
func _make_room(room_name, door_info, enemy_spawn, room_pos):
    var room = load(room_name)
    var room_instance = room.instance()
    room_instance._room_info.door = door_info
    room_instance._room_info.enemy_spawn = enemy_spawn
    room_instance._room_info.navi_transform = room_pos
    room_instance.global_transform.origin = (room_pos)
    add_child(room_instance)