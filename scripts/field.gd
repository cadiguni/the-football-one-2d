class_name Field
extends Node2D

## Playable area, in world coordinates. The goal lines are its left and right edges.
const RECT := Rect2(80, 60, 1120, 600)
const GOAL_WIDTH := 140.0
const GOAL_DEPTH := 36.0
## How far players may run beyond the field lines.
const PLAYER_BOUNDS_MARGIN := 30.0

const PENALTY_AREA := Vector2(160, 360)
const GOAL_AREA := Vector2(60, 180)
const CENTER_CIRCLE_RADIUS := 80.0
const STRIPES := 10
const LINE_WIDTH := 3.0

const GRASS := Color("2e7d32")
const GRASS_STRIPE := Color("388e3c")
const LINE := Color(1, 1, 1, 0.9)
const NET := Color(1, 1, 1, 0.25)


static func goal_top() -> float:
	return RECT.get_center().y - GOAL_WIDTH / 2


static func goal_bottom() -> float:
	return RECT.get_center().y + GOAL_WIDTH / 2


static func in_goal_mouth(y: float) -> bool:
	return y > goal_top() and y < goal_bottom()


func _draw() -> void:
	draw_rect(RECT.grow(PLAYER_BOUNDS_MARGIN + 10), GRASS)
	var stripe_width := RECT.size.x / STRIPES
	for i in range(0, STRIPES, 2):
		draw_rect(Rect2(RECT.position.x + i * stripe_width, RECT.position.y, stripe_width, RECT.size.y), GRASS_STRIPE)

	var center := RECT.get_center()
	draw_rect(RECT, LINE, false, LINE_WIDTH)
	draw_line(Vector2(center.x, RECT.position.y), Vector2(center.x, RECT.end.y), LINE, LINE_WIDTH)
	draw_arc(center, CENTER_CIRCLE_RADIUS, 0, TAU, 64, LINE, LINE_WIDTH)
	draw_circle(center, 4, LINE)

	_draw_side(RECT.position.x, 1)
	_draw_side(RECT.end.x, -1)


## Draws the areas and the goal at one end. [param inward] points towards the center of the field.
func _draw_side(line_x: float, inward: int) -> void:
	var center_y := RECT.get_center().y
	for area in [PENALTY_AREA, GOAL_AREA]:
		draw_rect(Rect2(line_x, center_y - area.y / 2, area.x * inward, area.y).abs(), LINE, false, LINE_WIDTH)
	draw_circle(Vector2(line_x + 110 * inward, center_y), 3, LINE)

	var goal := Rect2(line_x, goal_top(), -GOAL_DEPTH * inward, GOAL_WIDTH).abs()
	draw_rect(goal, NET)
	draw_rect(goal, LINE, false, LINE_WIDTH)
