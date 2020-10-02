extends Node2D

const PLAYER_MAX_HEALTH : int = 3
const PLAYER_MAX_SPEED : float = 250.0
const PLAYER_ACCELERATION : float = 0.2
const PLAYER_DECELERATION : float = 0.1
const PLAYER_TURN_SPEED : float = 20.0
const PRIMARY_FIRE_CD : float = 0.1
const POWERUP_DURATION : float = 10.0
const JOY_LEFT_DEADZONE : float = 0.05
const JOY_RIGHT_DEADZONE : float = 0.5
const JOY_CROSSHAIR_DISTANCE : float = 120.0
const PLAYER_INVINCE_TIME : float = 1.5
const PLAYER_FLICKER_TIME : float = 0.1

onready var bullet_scene = load("res://Scenes/Bullet.tscn")
onready var pf_timer : Timer = $PrimaryFireTimer
onready var inv_timer : Timer = $InvincibilityTimer
onready var flicker_timer : Timer = $SpriteFlickerTimer
onready var collection_radius : Area2D = $CollectionRadius
onready var joy_crosshair : Sprite = $Crosshair
onready var interface : CanvasLayer = get_tree().get_root().get_node("World/Interface")
onready var powerup_timers = {
    0: $PowerupTimers/SurroundTimer,
    1: $PowerupTimers/BarrierTimer,
    2: $PowerupTimers/MultishotTimer,
    3: $PowerupTimers/HomingTimer
}

var current_velocity : Vector2
var movement_vector : Vector2
var current_aim : Vector2
var aim_vector : Vector2
var aimed_mouse : bool = false
var current_health : int = PLAYER_MAX_HEALTH

# Updates
func _ready():
    pass
    
func _process(delta):
    process_input(delta)
    process_movement(delta)
    process_rotation(delta)
    update_crosshair_position()
    attempt_collect_powerups()
    update_barrier_sprite()
    invincibility_sprite_flicker()
    check_for_death()

func _input(event):
    if event is InputEventMouseMotion:
        if Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN:
            get_viewport().warp_mouse(joy_crosshair.global_position)
            
        interface.enable_mouse_cursor()
        aimed_mouse = true
    
func process_input(_delta):
    movement_vector = get_movement_vector()
    aim_vector = get_aim_joystick()
    
    if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
        aim_vector = get_global_mouse_position() - global_position

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
    var visual_size = get_viewport().get_visible_rect().size
    global_position.x = clamp(global_position.x, 0, visual_size.x)
    global_position.y = clamp(global_position.y, 0, visual_size.y)    
    
func attempt_collect_powerups():
    var areas = collection_radius.get_overlapping_areas()
    if !areas.empty():
        var powerup = areas[0].get_parent()
        
        if powerup.get_parent() != null:
            powerup_timers[powerup.powerup_type].start(POWERUP_DURATION)
            
        powerup.self_destruct()
        
func cancel_powerup(powerup : int):
    powerup_timers[powerup].stop()
    
func has_powerup(powerup : int):
    return powerup_timers[powerup].time_left > 0

func update_crosshair_position():
    var angle_vec = Vector2(cos(global_rotation), sin(global_rotation))
    joy_crosshair.global_position = global_position + angle_vec*JOY_CROSSHAIR_DISTANCE
    joy_crosshair.global_rotation = 0

func take_damage_from_enemy(damage_amount : int):
    if inv_timer.time_left > 0:
        return
        
    if has_powerup(1):
        cancel_powerup(1)
        
    else:
        current_health -= damage_amount
        
    current_health = int(max(0, current_health))
        
    inv_timer.start(PLAYER_INVINCE_TIME)
    flicker_timer.start(PLAYER_FLICKER_TIME)

func invincibility_sprite_flicker():
    if inv_timer.time_left > 0:
        if flicker_timer.time_left == 0:
            $PlayerSprite.visible = !$PlayerSprite.visible
            flicker_timer.start(PLAYER_FLICKER_TIME)
        
    else:
        $PlayerSprite.visible = true
        
    
func check_for_death():
    if current_health <= 0:
        self_destruct()
        
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
        
    if move_vec.length() < JOY_LEFT_DEADZONE:
        return Vector2.ZERO
        
    return move_vec

func get_aim_joystick() -> Vector2:
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
    
    if aim_vec.length() < JOY_RIGHT_DEADZONE:
        return Vector2.ZERO
        
    interface.enable_joystick_cursor()
    return aim_vec.normalized()
    
func update_barrier_sprite():
    $BarrierSprite.visible = powerup_timers[1].time_left > 0

# Actions
func action_primary_fire():
    if current_aim.length() == 0:
        return
        
    var bullet_obj = bullet_scene.instance()
    get_parent().add_child(bullet_obj)
    
    bullet_obj.set_initial_position(global_position)
    bullet_obj.set_bullet_velocity(current_aim)
    
    pf_timer.start(PRIMARY_FIRE_CD)

func self_destruct():
    if is_inside_tree():
        get_parent().remove_child(self)
