class_name Player
extends Node2D

const RADIUS := 14.0
const SPEED := 230.0
const ACCELERATION := 1600.0
## Extra reach beyond touching the ball within which a kick connects.
const KICK_RANGE := 12.0
const KICK_POWER := 650.0
## How long a kick press waits for the ball to come into range.
const KICK_BUFFER := 0.15

## 0 defends the left goal, 1 defends the right goal.
@export var team := 0
@export var color := Color.RED

## Set by whoever controls this player (keyboard, network or AI) before each step.
var input_dir := Vector2.ZERO
var velocity := Vector2.ZERO
var facing := Vector2.RIGHT
var spawn_position := Vector2.ZERO

var _kick_timer := 0.0


func _ready() -> void:
	spawn_position = position
	reset()


func reset() -> void:
	position = spawn_position
	velocity = Vector2.ZERO
	facing = Vector2.RIGHT if team == 0 else Vector2.LEFT
	_kick_timer = 0.0
	queue_redraw()


func request_kick() -> void:
	_kick_timer = KICK_BUFFER


## True while a kick request is still waiting for the ball.
func wants_kick() -> bool:
	return _kick_timer > 0.0


func consume_kick() -> void:
	_kick_timer = 0.0


func step(delta: float) -> void:
	var direction := input_dir.limit_length(1.0)
	velocity = velocity.move_toward(direction * SPEED, ACCELERATION * delta)
	if direction != Vector2.ZERO:
		facing = direction.normalized()
	position += velocity * delta

	var bounds := Field.RECT.grow(Field.PLAYER_BOUNDS_MARGIN)
	position = position.clamp(bounds.position + Vector2.ONE * RADIUS, bounds.end - Vector2.ONE * RADIUS)
	_kick_timer = maxf(_kick_timer - delta, 0.0)
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, color)
	draw_arc(Vector2.ZERO, RADIUS, 0, TAU, 32, color.darkened(0.5), 2.0)
	draw_line(Vector2.ZERO, facing * RADIUS, Color.WHITE, 3.0)
