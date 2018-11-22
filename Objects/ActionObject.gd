extends Area

var _move_pos
var _use_key_ui

func _ready():
    _move_pos = $MovePos
    var game_scene = get_tree().root.get_children()[0]
    _use_key_ui = game_scene.get_node("Hud/UseKey")
    
    self.connect("body_entered", self, "room_enter")
    self.connect("body_exited", self, "room_exit")
    
    set_process(false)
    
    
func room_enter(body):
    set_process(true)
    _use_key_ui.show()
    
    
func room_exit(body):
    set_process(false)
    _use_key_ui.hide()
    
    
func _process(delta):
    if Input.is_action_just_pressed("action_use"):
        on_input_use()


func on_input_use():
    pass
