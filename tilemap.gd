tool
extends Node
export var generate = false
export var clear = false
export(Texture) var texture
export var tilesize = Vector2(16,16)
export var tile_to_map = Vector2(0,0)


func _process(delta):
	if clear:
		for i in get_children():
			i.queue_free()
		clear = false
	
	if generate:
		texture.get_data().lock()
		generate = false
		if texture != null and get_child_count() < 1:
			var w
			var h
			var own = get_tree().get_edited_scene_root()
			if tile_to_map == Vector2():
				w = texture.get_size().x / tilesize.x
				h = texture.get_size().y / tilesize.y
			else:
				w = tile_to_map.x
				h = tile_to_map.y
			for x in range(0,w):
				for y in range(0,h):
					var pos = Vector2(x,y)*tilesize
					var empty = true
					for xp in range(0,tilesize.x):
						for yp in range(0,tilesize.y):
							if texture.get_data().get_pixel(pos.x + xp,pos.y + yp).r != 0 or \
							texture.get_data().get_pixel(pos.x + xp,pos.y + yp).g != 0 or \
							texture.get_data().get_pixel(pos.x + xp,pos.y + yp).b != 0 :
								empty = empty && false
					if empty:
						continue 
					var nd = Sprite.new()
					nd.position = pos + Vector2(x,y)
					nd.texture = texture
					nd.region_enabled = true
					nd.region_rect = Rect2(pos,tilesize)
					add_child(nd)
					nd.set_owner(own)
			texture.get_data().unlock()
	pass
