class_name Walker
extends Pawn

onready var parent = get_parent()
export var movement_range = 2
export var show_movement = false
export(NodePath) var overlay_path
onready var overlay = get_node_or_null(overlay_path)

var cell setget , _get_cell

func _get_cell():
	return parent.calculate_grid_coordinates(self.position)

func _ready():
	update_look_direction(Vector2.DOWN)
	show_movement()
	
func _process(_delta):
	var input_direction = get_input_direction()
	if not input_direction:
		return
	update_look_direction(input_direction)

	var target_position = parent.request_move(self, input_direction)
	if target_position:
		move_to(target_position)
		$Tween.start()
	else:
		bump()

func update_look_direction(direction):
	$Pivot/Sprite.rotation = direction.angle() - PI/2
	
func get_input_direction():
	return Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)


func move_to(target_position):
	cell = target_position
	set_process(false)
	$AnimationPlayer.play("walk")
	var move_direction = (position - target_position).normalized()
	$Tween.interpolate_property($Pivot, "position", move_direction * 8, Vector2(), $AnimationPlayer.current_animation_length, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Pivot/Sprite.position = position - target_position
	position = target_position

	show_movement()
	yield($AnimationPlayer, "animation_finished")
	set_process(true)


func show_movement():
	if show_movement and overlay:
		var cells = parent.get_walkable_cells(self)
		print("movable cells %s" % cells.size())
		overlay.draw(cells)

func bump():
	$AnimationPlayer.play("bump")
