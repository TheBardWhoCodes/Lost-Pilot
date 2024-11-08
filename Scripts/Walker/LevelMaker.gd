extends RefCounted
class_name LevelMaker

var extra_steps: int = 1
var number_of_steps: int = 100

const PADDING: int = 10

var level: Array[Vector2i]
var rng = RandomNumberGenerator.new()
var master_seed: String

func is_floor(tile: Vector2i) -> bool:
	var idx = level.bsearch(tile)
	if idx < level.size():
		if tile == level[idx]:
			return true
	return false

func setup_walkers(number_of_walkers: int) -> Array[Walker]:
	var walkers: Array[Walker] = []
	for number in number_of_walkers:
		var walker = Walker.new()
		walker.walker_position = Vector2i(0, number)
		walkers.append(walker)
	
	return walkers

## Reserves a space in the level for a floor tile
func place_floor_tile(new_tile: Vector2i) -> bool:
		var idx = level.bsearch(new_tile)
		if idx < level.size():
			if level[idx] == new_tile:
				return false
		level.insert(idx, new_tile)
		return true

## Generates a level with a random walker
func make_level() -> void:
	level.clear()
	print(master_seed)
	if master_seed:
		rng.seed = hash(master_seed)
	
	var walker = Walker.new()
	
	for step in number_of_steps:
		var new_tile = walker.step()
		
		var original_direction = walker.walker_direction
		var possible_directions: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN]
		
		# Prevent 180 turns so that we don't get TOO crazy with the floors we generate
		possible_directions.erase(-original_direction)
		
		# Pick a random direction
		var random_direction = possible_directions[rng.randi_range(0,2)]
		
		# We can optionally add extra width to the steps, Handling that here
		if original_direction == Vector2i.LEFT or original_direction == Vector2i.RIGHT:
			for extra_step in extra_steps:
				place_floor_tile.call(new_tile + Vector2i(0, extra_step + 1))
		elif original_direction == Vector2i.UP or original_direction == Vector2i.DOWN:
			for extra_step in extra_steps:
				place_floor_tile.call(new_tile + Vector2i(extra_step + 1, 0))
		
		# Place the main walkers step
		place_floor_tile.call(new_tile)
		
		# Go in a random direction, WOO!
		walker.set_direction(random_direction)

## Gets the level
func get_level() -> Array[Vector2i]:
	return level

## Gets the bounds of the level
func get_level_bounds() -> Rect2i:
	var bottom_left_corner := level[0]
	var top_right_corner: Vector2i = Vector2i.ZERO
	var bounds: Rect2i
	
	for tile in level:
		bottom_left_corner.x = min(tile.x, bottom_left_corner.x)
		bottom_left_corner.y = min(tile.y, bottom_left_corner.y)
		top_right_corner.x = max(tile.x, top_right_corner.x)
		top_right_corner.y = max(tile.y, top_right_corner.y)
	
	# Add some padding to the bounds so that we have room for walls
	bounds.position = bottom_left_corner + (Vector2i.UP * PADDING) + (Vector2i.LEFT * PADDING)
	bounds.end = top_right_corner+ (Vector2i.RIGHT  * PADDING) + (Vector2i.DOWN * PADDING) 
	
	return bounds
