extends Spatial


func _ready():
    var anim_player = $AnimationPlayer
    var anim = anim_player.get_animation("SwingRope")
    anim.set_loop(true)
    anim_player.play("SwingRope")
