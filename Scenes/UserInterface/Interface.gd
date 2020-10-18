extends CanvasLayer

onready var pause_screen = $Centered/SettingsMenu
onready var buff_icons = $BotRight/TimedBuffIcons
onready var buff_icon_scene = load("res://Scenes/UserInterface/HUD/TimedBuffIcon.tscn")
onready var the_game = get_tree().get_root().get_node("Game")
onready var score_manager = get_tree().get_root().get_node("Game/ScoreManager")
onready var config = get_tree().get_root().get_node("Game/SettingsManager")
onready var background : TextureRect = get_tree().get_root().get_node("Game/Background/Sprite")
var time_when_paused : int = 0

func _ready():
    config.use_settings()

func _process(_delta):
    if Input.is_action_just_pressed("pause"):
        toggle_pause()
        
    config.use_settings()
    align_ui_elements()
    update_background_size()
    update_hud_text()
    
func update_hud_text():
    var elapsed_time = OS.get_unix_time() - the_game.start_time
    var minutes = elapsed_time / 60
    var seconds = elapsed_time % 60
    var string_time : String = "%02d:%02d" % [minutes, seconds]
    $TopRight/ElapsedTime.set_text("TIME: %s" % string_time)
    $TopLeft/CurrentScore.set_text("SCORE: %s" % score_manager.current_score)
    $BotLeft/Framerate.set_text("%s FPS" % Engine.get_frames_per_second())
    
func toggle_pause():
    var tree = get_tree()
    tree.paused = !tree.paused
    pause_screen.visible = tree.paused
    
    if tree.paused:
        enable_mouse_cursor()
        config.reset_temp_settings()
        time_when_paused = OS.get_unix_time()
        
    else:
        pause_screen.set_option_mode(false)
        pause_screen.visible = false
        the_game.start_time += OS.get_unix_time() - time_when_paused
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

func enable_joystick_cursor():
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    the_game.get_player().joy_crosshair.visible = true
    
func enable_mouse_cursor():
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    the_game.get_player().joy_crosshair.visible = false

func create_buff_icon(powerup : int):
    for icon in buff_icons.get_children():
        if icon.powerup_id == powerup:
            return
            
    var buff_icon = buff_icon_scene.instance()
    buff_icon.powerup_id = powerup
    buff_icons.add_child(buff_icon)

func update_background_size():
    var screen_size = get_viewport().get_visible_rect().size
    background.rect_size = (screen_size - background.rect_position)/background.rect_scale
