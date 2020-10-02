extends CanvasLayer

var SETTINGS : Dictionary = {
    "aspect_ratio": 0,
    "resolution_id": 2,
    "resolution_x": 1366,
    "resolution_y": 768,
    "display_mode": 0
}

var temp_settings : Dictionary
var previous_ratio_id = -1
var previous_reso_id = -1
var previous_dm = -1

onready var the_world = get_tree().get_root().get_node("World")
onready var pause_screen = $Centered/PauseScreen

func _ready():
    temp_settings = SETTINGS.duplicate()
    use_settings()

func _process(_delta):
    if Input.is_action_just_pressed("pause"):
        toggle_pause()
        
    use_settings()
    update_fps_counter()
    align_ui_elements()
    
func toggle_pause():
    var tree = get_tree()
    tree.paused = !tree.paused
    pause_screen.visible = tree.paused
    
    if tree.paused:
        enable_mouse_cursor()
        temp_settings = SETTINGS.duplicate()
        pause_screen.current_node = pause_screen.aspect_node
        pause_screen.place_cursor_on_current_node()
        
    else:
        temp_settings = {}

func align_ui_elements():
    var internal_x = ProjectSettings.get_setting("display/window/size/width")
    var internal_y = ProjectSettings.get_setting("display/window/size/height")
    var effective_x = get_viewport().get_visible_rect().size.x
    var effective_y = get_viewport().get_visible_rect().size.y
    
    $Centered.rect_global_position.x = 0.5*(effective_x - internal_x)
    $Centered.rect_global_position.y = 0.5*(effective_y - internal_y)
    $TopRight.rect_global_position.x = effective_x - internal_x
    $BotLeft.rect_global_position.y = effective_y - internal_y
    $TopCenter.rect_global_position.x = 0.5*(effective_x - internal_x)
    
func use_settings():        
    # Set display mode
    if get_setting("display_mode") == 0:
        OS.window_fullscreen = false
        OS.window_borderless = false
        
    if get_setting("display_mode") == 1:
        OS.window_fullscreen = true
        OS.window_borderless = false
        
    if get_setting("display_mode") == 2:
        OS.window_borderless = true
        OS.window_fullscreen = false
        
    # Update window resolution
    var screen_size = OS.get_screen_size()
    var desired_size = Vector2(get_setting("resolution_x"), get_setting("resolution_y"))
    
    if previous_ratio_id != get_setting("aspect_ratio") or previous_reso_id != get_setting("resolution_id"):
        previous_ratio_id = get_setting("aspect_ratio")
        previous_reso_id = get_setting("resolution_id")
        
        if get_setting("resolution_x") < screen_size.x and get_setting("resolution_y") < screen_size.y:
            OS.window_maximized = false
        
        OS.set_window_size(desired_size)
        center_window()
    
    # Center window if the display mode changed
    # Center window if the display mode changed
    if get_setting("display_mode") != previous_dm:
        previous_dm = get_setting("display_mode")
        center_window()
        
func get_setting(key: String):
    if SETTINGS.has(key):
        return SETTINGS[key]
    return null

func apply_temp_settings():
    SETTINGS = temp_settings.duplicate()

func get_temp_setting(key : String):
    if temp_settings.has(key):
        return temp_settings[key]
    return null
    
func set_temp_setting(key : String, value):
    temp_settings[key] = value

func get_visible_world_position() -> Array:
    # Returns the global_position of the top-left and bottom-right
    # corners of the visible world space as an array.
    # index 0 is top-left, index 1 is bot-right
    var world_size = get_viewport().get_visible_rect().size
    
    if the_world.is_player_alive():
        var player_pos = the_world.get_player().global_position
        var screen_pos = the_world.get_player_screen_position()
        var top_left = player_pos - screen_pos
        var bot_right = top_left + world_size
        
        return [top_left, bot_right]
    
    return [Vector2(0, 0), world_size]

func center_window():    
    var screen_size = OS.get_screen_size()
    var window_size = OS.get_window_size()
    OS.set_window_position(screen_size/2 - window_size/2)

func enable_joystick_cursor():
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    if the_world.is_player_alive():
        the_world.get_player().joy_crosshair.visible = true
    
func enable_mouse_cursor():
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    if the_world.is_player_alive():
        the_world.get_player().joy_crosshair.visible = false

func update_fps_counter():
    $BotLeft/Framerate.set_text("%s FPS" % Engine.get_frames_per_second())
