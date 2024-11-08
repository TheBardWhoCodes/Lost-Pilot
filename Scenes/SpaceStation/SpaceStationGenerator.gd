extends Node2D
class_name SpaceStationGenerator

const NO_TILE = Vector2i(-1,-1)
const WALL_TOP = Vector2i(5,2)
const WALL_TOP_PADDING = Vector2i(1, 4)
const WALL_BOTTOM = Vector2i(7,4)
const WALL_BOTTOM_PADDING = Vector2i(5, 3)
const WALL_RIGHT = Vector2i(8,6)
const WALL_LEFT = Vector2i(8, 6)
const WALL_UPPER_RIGHT_CORNER = Vector2i(0,7)
const WALL_UPPER_LEFT_CORNER = Vector2i(3,7)
const WALL_LOWER_RIGHT_CORNER = Vector2i(0,8)
const WALL_LOWER_LEFT_CORNER = Vector2i(6,7)
const BASIC_FLOOR = Vector2i(5, 0)
const BLANK_COLLISION_TILE = Vector2i(3, 8)

@export var master_seed: String = "Game Dev is hard"
@export var tilemap_layer: TileMapLayer
@export var camera: Camera2D
@onready var levelmaker: LevelMaker = LevelMaker.new()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("SPACE"):
		get_viewport().set_input_as_handled()
		make_level()
		pass
	if event.is_action_pressed("UP"):
		get_viewport().set_input_as_handled()
		camera.zoom *= 1.1
	if event.is_action_pressed("DOWN"):
		get_viewport().set_input_as_handled()
		camera.zoom /= 1.1

func make_level():
	tilemap_layer.clear()
	
	if master_seed:
		print(master_seed)
		levelmaker.master_seed = master_seed
		
	levelmaker.make_level()
	
	var level = levelmaker.get_level()
	var level_bounds = levelmaker.get_level_bounds()
	
	# Build the Space Station based on the generated level
	for x in range(level_bounds.position.x, level_bounds.end.x + 1):
		for y in range(level_bounds.position.y, level_bounds.end.y + 1):
			var tile = Vector2i(x, y)
			var tile_type := tilemap_layer.get_cell_atlas_coords(tile)
			
			if levelmaker.is_floor(tile):
				tilemap_layer.set_cell(tile, 1, BASIC_FLOOR)
			else:
				### ---- WALLS ---- ###
				if levelmaker.is_floor(tile + Vector2i.DOWN):
					tilemap_layer.set_cell(tile, 1, WALL_TOP)
					tilemap_layer.set_cell(tile + Vector2i.UP, 1, WALL_TOP_PADDING)
				elif levelmaker.is_floor(tile + Vector2i.UP):
					tilemap_layer.set_cell(tile, 1, WALL_BOTTOM)
					tilemap_layer.set_cell(tile + Vector2i.DOWN, 1, WALL_BOTTOM_PADDING)
				elif levelmaker.is_floor(tile + Vector2i.LEFT):
					tilemap_layer.set_cell(tile, 1, WALL_RIGHT)
				elif levelmaker.is_floor(tile + Vector2i.RIGHT): 
					tilemap_layer.set_cell(tile, 1, WALL_LEFT)
				### ------ CORNERS ------ ###
				elif levelmaker.is_floor(tile + Vector2i.DOWN + Vector2i.RIGHT):
					tilemap_layer.set_cell(tile, 1, WALL_LEFT)
					tilemap_layer.set_cell(tile + Vector2i.UP, 1, WALL_UPPER_LEFT_CORNER)
				elif levelmaker.is_floor(tile + Vector2i.UP + Vector2i.RIGHT):
					tilemap_layer.set_cell(tile, 1, WALL_LEFT)
					tilemap_layer.set_cell(tile + Vector2i.DOWN, 1, WALL_LOWER_LEFT_CORNER)
				elif levelmaker.is_floor(tile + Vector2i.DOWN + Vector2i.LEFT):
					tilemap_layer.set_cell(tile, 1, WALL_RIGHT)
					tilemap_layer.set_cell(tile + Vector2i.UP, 1, WALL_UPPER_RIGHT_CORNER)
				elif levelmaker.is_floor(tile + Vector2i.UP + Vector2i.LEFT):
					tilemap_layer.set_cell(tile, 1, WALL_RIGHT)
					tilemap_layer.set_cell(tile + Vector2i.DOWN, 1, WALL_LOWER_RIGHT_CORNER)
				elif tile_type != BLANK_COLLISION_TILE and tile_type != NO_TILE:
					#if it's not blank or no tile then it's probably part of a wall that we setup previously
					pass
				else:
					tilemap_layer.set_cell(tile, 1, BLANK_COLLISION_TILE)
	
	camera.position = tilemap_layer.map_to_local(tilemap_layer.get_used_rect().get_center())
