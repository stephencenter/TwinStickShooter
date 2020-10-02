extends Node2D

const POWERUP_LIFESPAN : float = 8.0
const POWERUP_FLICKER_START = 3.0
const POWERUP_FLICKER_TIME = 6.0

enum POWERUP_TYPES {SURROUND, BARRIER, MULTISHOT, HOMING}
var POWERUP_SPRITEMAP : Dictionary

var powerup_type : int
onready var sprite : Node2D = $Sprite
onready var lifespan_timer : Timer = $LifespanTimer
onready var flicker_timer : Timer = $SpriteFlickerTimer

# Updates
func _ready():
    POWERUP_SPRITEMAP = {
        POWERUP_TYPES.SURROUND: load("res://Sprites/powerup_surround_icon.png"),
        POWERUP_TYPES.BARRIER: load("res://Sprites/powerup_barrier_icon.png"),
        POWERUP_TYPES.MULTISHOT: load("res://Sprites/powerup_multishot_icon.png"),
        POWERUP_TYPES.HOMING: load("res://Sprites/powerup_homing_icon.png")
    }
    
    lifespan_timer.start(POWERUP_LIFESPAN)
    
func _process(_delta):
    flicker_sprite()
    if lifespan_timer.time_left == 0:
        self_destruct()

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
    if lifespan_timer.time_left < POWERUP_FLICKER_START:
        if flicker_timer.time_left == 0:
            $Sprite.visible = !$Sprite.visible
            flicker_timer.start(lifespan_timer.time_left/POWERUP_FLICKER_TIME)
            
func self_destruct():
    if is_inside_tree():
        get_parent().remove_child(self)
