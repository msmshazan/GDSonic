extends RayCast2D

func _ready():
	pass

func _physics_process(delta):
	var player = $"../../Player"
	if is_colliding():
		var obj = get_collider()
		if obj == player:
			if player.direction == player.FacingDir.Right:
				player.set_collision_layer_bit(1,false)
				player.set_collision_layer_bit(2,true)
				player.z_index = -1
			else:
				if player.direction == player.FacingDir.Left:
					player.set_collision_layer_bit(2,false)
					player.set_collision_layer_bit(1,true)
					player.z_index = 1
	pass
