extends KinematicBody2D
enum FacingDir {
	Left = 0,
	Right = 1
}
# change 1: gravity is a vector2
export(float) var speed = 50
var inslope = false
var invelocity = Vector2()
var direction = FacingDir.Left
var isjumping = false
var isground = false
var capsuledim = Vector2(0.25,0.4)
var circledim = Vector2(0.3,0.3)
# change 2: use normal to track rotation
var normal = Vector2(0, -1)
var motion = Vector2(0, 0)
export(float) var gravity = -normal * 9.8 * 2
var ppos = Vector2()
var velocity = Vector2()
func _ready():
	ppos = global_transform.origin

func get_input():
	motion = Vector2()
	# change 4: do not consider rotation yet, it's too soon
	isground = $LeftSensor.is_colliding() and $RightSensor.is_colliding()
	invelocity = Vector2()
	if Input.is_action_pressed('ui_right'):
		direction = FacingDir.Right
		invelocity.x += 1
		motion.x += 1
	if Input.is_action_pressed('ui_left'):
		direction = FacingDir.Left
		motion.x -= 1
		invelocity.x -= 1
	# gotta go fast
	motion = motion.normalized()*speed
	if Input.is_action_pressed('jump') and isground:
		isjumping = true
	
func switch_collision_shape(disableval):
	$Circle.disabled = disableval
	$Capsule.disabled = !disableval
	pass

func _physics_process(delta):
	get_input()
	gravity = -normal * 9.8 * 2
	motion = motion.rotated(rotation) * delta
	if isjumping :
		motion = normal*5
		isjumping = false
	velocity += motion
	if !isground:
		if velocity.y > 0:
			velocity += 2*gravity*delta
		velocity += gravity*delta
		velocity.x *= 0.85
	else:
		velocity *= 0.65
	# change 6: loop collisions, 8 attempts to resolve
	var collision = move_and_collide(velocity)
	# increase attempts if you find it gets stuck in corners
	var max_attempts = 12
	var attempts = max_attempts
	while collision and collision.remainder.length() > 0.01 and attempts:
		# more readable names :)
		var other = collision.collider
		var remainder = collision.remainder
		# update our "up"
		if inslope :
			normal = collision.normal
		var angle = abs(round(rad2deg(normal.angle_to(Vector2(0,-1)))))
		if inslope :
			# remember: gravity direction is really just the opposite of up
			# update our current rotation (angle of up + a quarter circle)
			rotation = normal.rotated(PI *.5).angle()
		# attempt to use the rest of our force
		velocity = remainder
		collision = move_and_collide(remainder.slide(normal))
		attempts -= 1
	
	if attempts == max_attempts:
		if inslope :
			normal = normal.linear_interpolate(Vector2(0, -1), 0.1)
			rotation = normal.rotated(PI *.5).angle()
	
	var pos = global_transform.origin 
	var velocity = (pos - ppos)/delta
	ppos = pos
	if isjumping and velocity.y > 0:
		isjumping = false
	if !isground:
		$Sprite.play("jump")
		$Sprite.scale = circledim
		switch_collision_shape(false)
	else:
		$Sprite.scale = capsuledim
		switch_collision_shape(true)
		if (invelocity.x) < 0:
			if $Sprite.animation != "walk_left":
				$Sprite.stop()
				$Sprite.play("walk_left")
			direction = FacingDir.Left
		if (invelocity.x) > 0:
			if $Sprite.animation != "walk_right":
				$Sprite.stop()
				$Sprite.play("walk_right")
			direction = FacingDir.Right
		if (invelocity.x) == 0:
			if direction == FacingDir.Left: 
				if $Sprite.is_playing():
					$Sprite.stop()
					$Sprite.play("stand_left")
			if direction == FacingDir.Right:
				if $Sprite.is_playing():
					$Sprite.stop()
					$Sprite.play("stand_right")
	pass