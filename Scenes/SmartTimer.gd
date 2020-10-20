extends Node
# This is a special class that I use instead of the vanilla Timer class
# It works just like the normal timer, except it only processes during
# specific gamestates
var the_game
var active_states : Array
var time_left : float

func _init(var states : Array, var root):
    active_states = states
    root.call_deferred("add_child", self)
    the_game = root
    
func _process(delta):
    if !the_game.is_any_current_state(active_states):
        return
        
    time_left -= delta
    time_left = max(0, time_left)

func start(new_time : float):
    time_left = new_time
