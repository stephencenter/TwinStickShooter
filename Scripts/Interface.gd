extends CanvasLayer

onready var pause_screen = $Centered/SettingsMenu
onready var buff_icon_scene = load("res://Scenes/TimedBuffIcon.tscn")
onready var buff_icons = $BotRight/TimedBuffIcons
onready var the_world = get_tree().get_root().get_node("Game")
onready var config = get_tree().get_root().get_node("Game/SettingsManager")
onready var background : TextureRect = get_tree().get_root().get_node("Game/Background/Sprite")
var time_when_paused : int = 0

func _ready():
    config.use_settings()

func _process(_delta):
    if Input.is_action_just_pressed("pause"):
        toggle_pause()
        
    config.use_settings()
    update_fps_counter()
    align_ui_elements()
    update_background_size()
    if !get_tree().paused:
        update_hud_text()
    
func update_hud_text():
    $TopLeft/CurrentScore.set_text("SCORE: %s" % the_world.current_score)
    var elapsed_time = OS.get_unix_time() - the_world.start_time
    var minutes = elapsed_time / 60
    var seconds = elapsed_time % 60
    var string_time : String = "%02d:%02d" % [minutes, seconds]
    $TopRight/ElapsedTime.set_text("TIME: %s" % string_time)
    
func toggle_pause():
    var tree = get_tree()
    tree.paused = !tree.paused
    pause_screen.visible = tree.paused
    
    if tree.paused:
        enable_mouse_cursor()
        config.reset_temp_settings()
        pause_screen.current_node = pause_screen.aspect_node
        pause_screen.place_cursor_on_current_node()
        time_when_paused = OS.get_unix_time()
        
    else:
        the_world.start_time += OS.get_unix_time() - time_when_paused
        config.clear_temp_settings()

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
    $BotRight.rect_global_position.x =  effective_x - internal_x
    $BotRight.rect_global_position.y =  effective_y - internal_y

func get_visible_world_position() -> Array:
    # Returns the global_position of the top-left and bottom-right
    # corners of the visible world space as an array.
    # index 0 is top-left, index 1 is bot-right
    var world_size = get_viewport().get_visible_rect().size
    var player_pos = the_world.get_player().global_position
    var screen_pos = the_world.get_player_screen_position()
    var top_left = player_pos - screen_pos
    var bot_right = top_left + world_size
    
    return [top_left, bot_right]

func enable_joystick_cursor():
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    the_world.get_player().joy_crosshair.visible = true
    
func enable_mouse_cursor():
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    the_world.get_player().joy_crosshair.visible = false

func update_fps_counter():
    $BotLeft/Framerate.set_text("%s FPS" % Engine.get_frames_per_second())

func create_buff_icon(powerup : int):
    for icon in buff_icons.get_children():
        if icon.powerup_id == powerup:
            return
            
    var buff_icon = buff_icon_scene.instance()
    buff_icon.powerup_id = powerup
    buff_icons.add_child(buff_icon)

func update_background_size():
    var world_size = get_viewport().get_visible_rect().size
    background.rect_size = (world_size - background.rect_position)/background.rect_scale

func is_object_on_screen(object) -> bool:
    var visible_pos =  get_visible_world_position()
    var top_left = visible_pos[0]
    var bot_right = visible_pos[1]
    
    if object.global_position.x > top_left.x:
        if object.global_position.x < bot_right.x:
            if object.global_position.y > top_left.y:
                if object.global_position.y < bot_right.y:
                    return true
    return false
