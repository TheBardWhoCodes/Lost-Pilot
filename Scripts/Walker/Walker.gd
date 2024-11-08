extends RefCounted
class_name Walker

var walker_position: Vector2i
var walker_direction: Vector2i

func _init(new_position: Vector2i = Vector2i.ZERO, new_direction: Vector2i = Vector2i.RIGHT) -> void:
	walker_position = new_position
	walker_direction = new_direction

func step() -> Vector2i:
	walker_position += walker_direction
	return walker_position
	
func set_direction(new_direction: Vector2i) -> void:
	walker_direction = new_direction
