extends Node

var _player

var _loader
var _wait_frames
var _time_max = 100 # msec
var _current_scene


func _ready():
    _player = $Player
    _player.global_transform.origin = Vector3(0, 0, -60)
    
    change_scene("res://Rooms/Home.tscn")
        
        
func change_scene(path):
    _loader = ResourceLoader.load_interactive(path)
    if _loader == null: # check for errors
        #show_error()
        return
        
    set_process(true)

    if _current_scene:
        _current_scene.queue_free() # get rid of the old scene

    # start your "loading..." animation
    #get_node("animation").play("loading")

    _wait_frames = 1
    
    
func _process(time):
    if _loader == null:
        # no need to process anymore
        set_process(false)
        return

    if _wait_frames > 0: # wait for frames to let the "loading" animation to show up
        _wait_frames -= 1
        return

    var t = OS.get_ticks_msec()
    while OS.get_ticks_msec() < t + _time_max: # use "time_max" to control how much time we block this thread

        # poll your loader
        var err = _loader.poll()

        if err == ERR_FILE_EOF: # load finished
            var resource = _loader.get_resource()
            _loader = null
            set_new_scene(resource)
            break
            
        elif err == OK:
            update_progress()
            
        else: # error during loading
            #show_error()
            _loader = null
            break
            
            
func update_progress():
    var progress = float(_loader.get_stage()) / _loader.get_stage_count()
    # update your progress bar?
    #get_node("progress").set_progress(progress)

    # or update a progress animation?
    #var len = get_node("animation").get_current_animation_length()

    # call this on a paused animation. use "true" as the second parameter to force the animation to update
    #get_node("animation").seek(progress * len, true)

func set_new_scene(scene_resource):
    _current_scene = scene_resource.instance()
    get_node("/root").add_child(_current_scene)