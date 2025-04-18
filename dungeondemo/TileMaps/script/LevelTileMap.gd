class_name LevelTileMap extends TileMap

@export var tile_size : float = 32
@export var update_bounds : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if update_bounds:
		var bounds = _get_tilemap_bounds()
		print("Calculated Bounds:", bounds)
		LevelManager.change_tilemap_bounds(bounds)

func _get_tilemap_bounds() -> Array[Vector2]:
	var used_rect = get_used_rect()
	print("Used Rect:", used_rect)
	var pos = position
	print("Position:", pos)
	var ts = tile_size
	print("Tile Size:", ts)
	
	var top_left = Vector2(used_rect.position * ts) + pos
	var bottom_right = Vector2(used_rect.end * ts) + pos
	
	print("Top Left:", top_left)
	print("Bottom Right:", bottom_right)
	
	var bounds : Array[Vector2] = []
	bounds.append(top_left)
	bounds.append(bottom_right)
	return bounds
