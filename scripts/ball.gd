class_name Ball
extends Node2D

## Emitted when the ball fully crosses a goal line. [param team] is the team that scored.
signal goal_scored(team: int)

const RADIUS := 8.0
## Exponential slowdown per second while rolling.
const DAMPING := 1.2
## Fraction of speed kept after hitting a line or the net.
const BOUNCE := 0.7
const STOP_SPEED := 5.0

var velocity := Vector2.ZERO


func step(delta: float) -> void:
	velocity *= exp(-DAMPING * delta)
	if velocity.length() < STOP_SPEED:
		velocity = Vector2.ZERO
	position += velocity * delta
	_collide_with_bounds()


func reset(at: Vector2) -> void:
	position = at
	velocity = Vector2.ZERO


func _collide_with_bounds() -> void:
	var r := Field.RECT
	if position.x < r.position.x or position.x > r.end.x:
		# Behind a goal line the ball can only be inside the goal, so the net holds it vertically.
		_bounce_y(Field.goal_top() + RADIUS, Field.goal_bottom() - RADIUS)
		if position.x + RADIUS < r.position.x:
			goal_scored.emit(1)
		elif position.x - RADIUS > r.end.x:
			goal_scored.emit(0)
		return

	_bounce_y(r.position.y + RADIUS, r.end.y - RADIUS)
	if not Field.in_goal_mouth(position.y):
		if position.x - RADIUS < r.position.x:
			position.x = r.position.x + RADIUS
			velocity.x = absf(velocity.x) * BOUNCE
		elif position.x + RADIUS > r.end.x:
			position.x = r.end.x - RADIUS
			velocity.x = -absf(velocity.x) * BOUNCE


func _bounce_y(top: float, bottom: float) -> void:
	if position.y < top:
		position.y = top
		velocity.y = absf(velocity.y) * BOUNCE
	elif position.y > bottom:
		position.y = bottom
		velocity.y = -absf(velocity.y) * BOUNCE


func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, Color.WHITE)
	draw_arc(Vector2.ZERO, RADIUS, 0, TAU, 24, Color(0.1, 0.1, 0.1), 1.5)
