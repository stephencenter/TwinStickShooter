extends Control

onready var the_game = get_tree().get_root().get_node("Game")
onready var ACTIVE_STATES : Array = [the_game.GameState.OPTIONS]

onready var aspect_node : Control = $AspectRatio
onready var resolution_node : Control = $Resolution
onready var windowed_node : Control = $DisplayMode/Windowed
onready var fullscreen_node : Control = $DisplayMode/Fullscreen
onready var borderless_node : Control = $DisplayMode/Borderless
onready var apply_node : Control = $Apply
onready var resume_node : Control = $Resume
onready var nothing_node : Control = $Nothing

# These arrays specify which node you go to when you press each direction
# First element is Up, second is Down, then Left, the Right
onready var navigation_map : Dictionary = {
    aspect_node: [null, resolution_node, null, null],
    resolution_node: [aspect_node, windowed_node, null, null],
    windowed_node: [resolution_node, apply_node, null, fullscreen_node],
    fullscreen_node: [resolution_node, apply_node, windowed_node, borderless_node],
    borderless_node: [resolution_node, apply_node, fullscreen_node, null],
    resume_node: [windowed_node, null, null, apply_node],
    apply_node: [windowed_node, null, resume_node, null],
    nothing_node: [aspect_node, aspect_node, aspect_node, aspect_node]
}

onready var current_node : Control = nothing_node
var using_option_button : bool = false
var original_ob_selection : int

func _process(_delta):    
    if !the_game.is_any_current_state(ACTIVE_STATES):
        return
            
    if using_option_button:
        handle_option_buttons()
        
    else:
        navigate_menu()

func _input(event):
    if event is InputEventMouseMotion and using_option_button:            
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        set_option_mode(false)
        
func navigate_menu(): 
    if Input.is_action_just_pressed("ui_up"):
        if navigation_map[current_node][0] != null:
            current_node = navigation_map[current_node][0]
            place_cursor_on_current_node()
            
    if Input.is_action_just_pressed("ui_down"):
        if navigation_map[current_node][1] != null:
            current_node = navigation_map[current_node][1]
            place_cursor_on_current_node()
            
    if Input.is_action_just_pressed("ui_left"):
        if navigation_map[current_node][2] != null:
            current_node = navigation_map[current_node][2]
            place_cursor_on_current_node()
            
    if Input.is_action_just_pressed("ui_right"):
        if navigation_map[current_node][3] != null:
            current_node = navigation_map[current_node][3]
            place_cursor_on_current_node()
            
    if Input.is_action_just_pressed("ui_accept"):
        press_current_node_button()
        
func handle_option_buttons():
    var button : Button = current_node.get_node("Clickable")
    var arrow_left = current_node.get_node("ArrowLeft")
    var arrow_right = current_node.get_node("ArrowRight")
    
    var max_index = button.get_item_count() - 1
    var current_index = button.get_selected_id()
    
    if Input.is_action_just_pressed("ui_left"):
        if current_index > 0:
            button.select(current_index - 1)
            
    if Input.is_action_just_pressed("ui_right"):
        if current_index < max_index:
            button.select(current_index + 1)
            
    if current_index > 0:
        arrow_left.visible = true
    else:
        arrow_left.visible = false
    
    if current_index < max_index:
        arrow_right.visible = true
    else:
        arrow_right.visible = false
    
    if Input.is_action_just_pressed("ui_accept"):
        set_option_mode(false)
        
    if Input.is_action_just_pressed("ui_cancel"):
        button.select(original_ob_selection)
        set_option_mode(false)
    
func place_cursor_on_current_node():
    var button = current_node.get_node("Clickable")
    var node_pos = button.rect_global_position
    var node_size = button.rect_size*button.rect_scale
    var new_position = node_pos + node_size/2
    
    get_viewport().warp_mouse(new_position)

func press_current_node_button():
    var button : Button = current_node.get_node("Clickable")
    if button is OptionButton:
        original_ob_selection = button.get_selected_id()
        set_option_mode(true)
        
    else:
        button._pressed()

func set_option_mode(value : bool):
    if using_option_button and !value:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        current_node.get_node("ArrowLeft").visible = false
        current_node.get_node("ArrowRight").visible = false
        
    else:
        Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

    using_option_button = value
