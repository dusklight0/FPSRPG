extends Position3D

export(int) var _min_enemy_count
export(int) var _max_enemy_count

var _enemy_count

func _ready():
    _enemy_count = rand_range(_min_enemy_count, _max_enemy_count)
