extends Node2D

const PLAYER_MAX_SPEED : float = 250.0
const PLAYER_ACCELERATION : float = 0.2
const PLAYER_DECELERATION : float = 0.1
const PLAYER_TURN_SPEED : float = 15.0
const PRIMARY_FIRE_CD : float = 0.1

var current_velocity : Vector2
var movement_vector : Vector2
var current_aim : Vector2
var aim_vector : Vector2
var aimed_mouse : bool = false

onready var bullet_scene = load("res://Scenes/Bullet.tscn")
onready var the_world : Node2D = get_parent()
onready var pf_timer : Timer = $PrimaryFireTimer

# Updates
func _ready():
    current_aim = Vector2(cos(global_rotation), sin(global_rotation))
    
func _process(delta):
    process_input(delta)
    process_movement(delta)
    process_rotation(delta)

func _input(event):
    if event is InputEventMouseMotion:
        aimed_mouse = true
        aim_vector = event.position - global_position
    
func process_input(_delta):
    movement_vector = get_movement_vector()
    aim_vector = get_aim_vector()
    
    if Input.is_action_pressed("primary_fire"):
        if pf_timer.time_left == 0:
            action_primary_fire()

func process_movement(delta):
    movement_vector = movement_vector*PLAYER_MAX_SPEED
    
    if movement_vector.length() > 0:
        current_velocity = current_velocity.linear_interpolate(movement_vector, PLAYER_ACCELERATION)
    else:
        current_velocity = current_velocity.linear_interpolate(Vector2.ZERO, PLAYER_DECELERATION)
    
    global_position += current_velocity*delta
    clamp_position()
        
func process_rotation(delta):
    # The player's sprite doesn't just snap to the desired angle, it instead
    # gradually turns at a speed dependent on PLAYER_TURN_SPEED.
    # This is purely visual and does not affect the direction bullets are fired in.
    if aim_vector.length() > 0:
        current_aim = aim_vector
    
    # This calculates the desired angle based on joystick/cursor position, as
    # well as the shortest route to achieve that angle
    var desired_angle = int(rad2deg(current_aim.angle()))
    var current_angle = int(global_rotation_degrees)
    var difference = (desired_angle - current_angle + 540) % 360 - 180
      
    if abs(difference) < PLAYER_TURN_SPEED:
        global_rotation_degrees = desired_angle
    elif difference < 0:
        global_rotation -= PLAYER_TURN_SPEED*delta
    else:
        global_rotation += PLAYER_TURN_SPEED*delta

func clamp_position():
    var screen_size_x = ProjectSettings.get_setting("display/window/size/width")
    var screen_size_y = ProjectSettings.get_setting("display/window/size/height")
    global_position.x = clamp(global_position.x, 0, screen_size_x)
    global_position.y = clamp(global_position.y, 0, screen_size_y)
    
# Helpers
func get_movement_vector() -> Vector2:
    var move_vec : Vector2 = Vector2()
    
    if Input.is_action_pressed("move_up"):
        move_vec.y -= Input.get_action_strength("move_up")
    if Input.is_action_pressed("move_down"):
        move_vec.y += Input.get_action_strength("move_down")
    if Input.is_action_pressed("move_left"):
        move_vec.x -= Input.get_action_strength("move_left")
    if Input.is_action_pressed("move_right"):
        move_vec.x += Input.get_action_strength("move_right")
        
    return move_vec

func get_aim_vector() -> Vector2:
    if aimed_mouse:
        aimed_mouse = false
        return aim_vector
        
    var aim_vec : Vector2 = Vector2()
    
    if Input.is_action_pressed("aim_up"):
        aim_vec.y -= Input.get_action_strength("aim_up")
    if Input.is_action_pressed("aim_down"):
        aim_vec.y += Input.get_action_strength("aim_down")
    if Input.is_action_pressed("aim_left"):
        aim_vec.x -= Input.get_action_strength("aim_left")
    if Input.is_action_pressed("aim_right"):
        aim_vec.x += Input.get_action_strength("aim_right")
        
    return aim_vec.normalized()

# Actions
func action_primary_fire():
    var bullet_obj = bullet_scene.instance()
    the_world.add_child(bullet_obj)
    
    bullet_obj.set_initial_position(global_position)
    bullet_obj.set_bullet_velocity(current_aim)
    
    pf_timer.start(PRIMARY_FIRE_CD)

func self_destruct():
    var parent = get_parent()
    if parent != null:
        parent.remove_child(self)
