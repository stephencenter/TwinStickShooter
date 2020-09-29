extends Node2D

const POWERUP_LIFESPAN : float = 5.0
enum POWERUP_TYPES {SURROUND, BARRIER, MULTISHOT, HOMING}
var POWERUP_SPRITEMAP : Dictionary

var powerup_type : int
onready var sprite : Sprite = $Sprite
onready var lifespan_timer : Timer = $LifespanTimer

# Updates
func _ready():
    POWERUP_SPRITEMAP = {
        POWERUP_TYPES.SURROUND: load("res://Sprites/surround_powerup.png"),
        POWERUP_TYPES.BARRIER: load("res://Sprites/barrier_powerup.png"),
        POWERUP_TYPES.MULTISHOT: load("res://Sprites/multishot_powerup.png"),
        POWERUP_TYPES.HOMING: load("res://Sprites/homing_powerup.png")
    }
    
    lifespan_timer.start(POWERUP_LIFESPAN)
    
func _process(_delta):
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
    sprite.texture = POWERUP_SPRITEMAP[powerup_type]
    
func self_destruct():
    var parent = get_parent()
    if parent != null:
        parent.remove_child(self)
