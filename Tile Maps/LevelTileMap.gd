class_name LevelTileMap
extends TileMapLayer

func _ready():
	LevelManager.ChangeTilemapBounds( GetTilemapBounds() )
	pass
	
func GetTilemapBounds() -> Array[ Vector2 ]:
	var bounds : Array[ Vector2 ]= []
	bounds.append(
		Vector2( get_used_rect().position * rendering_quadrant_size )
	)
	print(bounds[0].x, bounds[0].y)
	
	bounds.append(
		Vector2( get_used_rect().end * rendering_quadrant_size)
	)
	print(bounds[1].x, bounds[1].y)
	return bounds
