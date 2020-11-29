extends Node2D

onready var the_game : Node2D = get_tree().get_root().get_node("Game")
onready var ACTIVE_STATES : Array = [the_game.GameState.INGAME]

const POWERUP_LIFESPAN : float = 12.0
const POWERUP_FLICKER_START = 3.0
const POWERUP_FLICKER_TIME = 6.0
enum POWERUP_TYPES {SURROUND=0, BARRIER=1, MULTISHOT=2, HOMING=3}

onready var timer_class = load("res://Scenes/SmartTimer.gd")
onready var sprite : Node2D = $Sprite
onready var flicker_timer = timer_class.new([the_game.GameState.INGAME], the_game)
onready var lifespan_timer = timer_class.new([the_game.GameState.INGAME], the_game)
onready var POWERUP_SPRITEMAP : Dictionary = {
    POWERUP_TYPES.SURROUND: load("res://Sprites/powerup_surround_icon.png"),
    POWERUP_TYPES.BARRIER: load("res://Sprites/powerup_barrier_icon.png"),
    POWERUP_TYPES.MULTISHOT: load("res://Sprites/powerup_multishot_icon.png"),
    POWERUP_TYPES.HOMING: load("res://Sprites/powerup_homing_icon.png")
}

var powerup_type : int

# Updates
func _ready():    
    lifespan_timer.start(POWERUP_LIFESPAN)
          
func _process(_delta):
    if not the_game.is_any_current_state(ACTIVE_STATES):
        return    
        
    flicker_sprite()
    if lifespan_timer.is_stopped():
        queue_free()

# Methods
func set_powerup_position(pos_vec : Vector2):
    global_position = pos_vec

func choose_powerup_type(previous_powerup : int) -> int:
    var options = []
    for option in POWERUP_TYPES.values():
        if option != previous_powerup:
            options.append(option)
        
    return options[randi() % options.size()]

func set_powerup_type(new_type : int):
    powerup_type = new_type
    sprite.get_node("Icon").texture = POWERUP_SPRITEMAP[powerup_type]

func flicker_sprite():
    var time_left = lifespan_timer.get_time_left()
    if time_left < POWERUP_FLICKER_START and flicker_timer.is_stopped():
        $Sprite.visible = not $Sprite.visible
        flicker_timer.start(time_left/POWERUP_FLICKER_TIME)
