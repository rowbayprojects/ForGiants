extends TileMap


var used_cells = get_used_cells(0)
var room = preload("res://Forge/room.tscn")


func _ready():
	for i in used_cells.size():
		var atlas_coords = get_cell_atlas_coords(0, used_cells[i])
		
		match atlas_coords:
			Vector2i(0, 0): # Room root
				var room_instance = room.instantiate()
				add_child(room_instance)
				room_instance.position = map_to_local(used_cells[i]) - Vector2(160, 88)
				
				if used_cells[i] == Vector2i(-1, -1):
					room_instance.add_to_group("forge_room")
				
				var room_width : int = 1
				var room_height : int = 1
				
				while get_cell_atlas_coords(0, used_cells[i] + Vector2i(room_width, 0)) == Vector2i(2, 0):
					room_width += 1
				while get_cell_atlas_coords(0, used_cells[i] + Vector2i(0, room_height)) == Vector2i(1, 0):
					room_height += 1
				
				room_instance.set_room_size(room_width, room_height)
	
	clear()
