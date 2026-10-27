extends Node2D

## Keyboard layout for each local player, in the same order as ACTIONS.
const LOCAL_BINDINGS := [
	[KEY_W, KEY_S, KEY_A, KEY_D, KEY_SPACE],
	[KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_ENTER],
]
const ACTIONS := ["up", "down", "left", "right", "kick"]

## How much of the player's own velocity a dribble touch passes on to the ball.
const DRIBBLE_BOUNCE := 0.3
## How much of the player's own velocity is added to a kick.
const KICK_CARRY := 0.3

var players: Array[Player] = []

@onready var ball: Ball = $Ball


func _ready() -> void:
	players.assign($Players.get_children())
	_register_inputs()
	ball.goal_scored.connect(_on_goal_scored)
	_kickoff()


func _physics_process(delta: float) -> void:
	_read_local_input()
	for player in players:
		player.step(delta)
	_separate_players()
	for player in players:
		_touch_ball(player)
	ball.step(delta)


func _register_inputs() -> void:
	for i in LOCAL_BINDINGS.size():
		for j in ACTIONS.size():
			var action := _action_name(i, ACTIONS[j])
			if InputMap.has_action(action):
				continue
			InputMap.add_action(action)
			var event := InputEventKey.new()
			event.physical_keycode = LOCAL_BINDINGS[i][j]
			InputMap.action_add_event(action, event)


func _action_name(player_index: int, action: String) -> String:
	return "p%d_%s" % [player_index + 1, action]


func _read_local_input() -> void:
	for i in mini(players.size(), LOCAL_BINDINGS.size()):
		var player := players[i]
		player.input_dir = Input.get_vector(
			_action_name(i, "left"), _action_name(i, "right"),
			_action_name(i, "up"), _action_name(i, "down"))
		if Input.is_action_just_pressed(_action_name(i, "kick")):
			player.request_kick()


## Pushes overlapping players apart, half each.
func _separate_players() -> void:
	for i in players.size():
		for j in range(i + 1, players.size()):
			var a := players[i]
			var b := players[j]
			var offset := b.position - a.position
			var overlap := Player.RADIUS * 2 - offset.length()
			if overlap > 0:
				var normal := offset.normalized() if offset != Vector2.ZERO else Vector2.RIGHT
				a.position -= normal * overlap / 2
				b.position += normal * overlap / 2


func _touch_ball(player: Player) -> void:
	var offset := ball.position - player.position
	var distance := offset.length()
	var contact := Player.RADIUS + Ball.RADIUS
	var normal := offset / distance if distance > 0.001 else player.facing

	if player.wants_kick() and distance <= contact + Player.KICK_RANGE:
		# Kick where the player is facing when the ball is in front, otherwise just away from them.
		var direction := player.facing if normal.dot(player.facing) > 0.3 else normal
		ball.velocity = direction * Player.KICK_POWER + player.velocity * KICK_CARRY
		player.consume_kick()
	elif distance < contact:
		ball.position = player.position + normal * contact
		var approach := (ball.velocity - player.velocity).dot(normal)
		if approach < 0:
			ball.velocity -= normal * approach * (1 + DRIBBLE_BOUNCE)


func _kickoff() -> void:
	ball.reset(Field.RECT.get_center())
	for player in players:
		player.reset()


func _on_goal_scored(team: int) -> void:
	print("Goal for team %d" % team)
	_kickoff()
