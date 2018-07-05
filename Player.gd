extends KinematicBody2D
enum FacingDir {
	Left = 0,
	Right = 1
}

export(float) var speed = 300
var inslope = false
var invelocity = Vector2()
var direction = FacingDir.Left
var isjumping = false
var isground = false
var capsuledim = Vector2(0.25,0.4)
var circledim = Vector2(0.3,0.3)

var normal = Vector2(0, 0)
export(float) var gravity = 9.8*20
var velocity = Vector2()
var acceleration = Vector2()

func _ready():
	pass

func get_input():
	isground = $LeftSensor.is_colliding() and $RightSensor.is_colliding()
	if isjumping and isground:
		isjumping = false
	invelocity = Vector2()
	if Input.is_action_pressed('ui_right'):
		direction = FacingDir.Right
		invelocity.x += 1
	if Input.is_action_pressed('ui_left'):
		direction = FacingDir.Left
		invelocity.x -= 1
	if Input.is_action_pressed('jump') and isground:
		isjumping = true
	if inslope: 
		velocity.x += invelocity.x*speed*cos(rotation)
		velocity.y += invelocity.x*speed*sin(rotation)
	else:
		velocity.x += invelocity.x*speed
	


func switch_collision_shape(disableval):
	$Circle.disabled = disableval
	$Capsule.disabled = !disableval
	pass


func _physics_process(dt):
	acceleration = Vector2()
	get_input()
	gravity = 9.8*80 
	velocity += velocity.rotated(rotation)*dt
	var pos = global_transform.origin
	if isjumping and isground:
		velocity = normal * 350
	if inslope:
		acceleration += -normal*gravity
		acceleration += Vector2(0,gravity)
	else:
		pass
	if velocity.y > 0 and not isground:
		acceleration += Vector2(0,gravity)
	acceleration += Vector2(0,gravity)
	
	velocity += acceleration * dt
	if isground:
		velocity *= 0.85
	else:
		velocity *= 0.75
		normal = Vector2(0,-1)
	velocity.x = clamp(velocity.x,-300,300)
	velocity.y = clamp(velocity.y,-300,300)
	var collisioninfo = move_and_collide(velocity * dt)
	var collisioncount = 0
	while collisioninfo and collisioninfo.remainder.length() > 0.001 and collisioncount < 10: 
		normal = collisioninfo.get_normal()
		collisioncount += 1
		collisioninfo = move_and_collide(collisioninfo.remainder)
	var angle = -normal.angle_to(Vector2(0,-1))
	rotation = angle
	if !isground and isjumping:
		$Sprite.play("jump")
		$Sprite.scale = circledim
		switch_collision_shape(false)
	else:
		$Sprite.scale = capsuledim
		switch_collision_shape(true)
		if round(velocity.x) != 0 and direction == FacingDir.Left:
			if $Sprite.animation != "walk_left":
				$Sprite.stop()
				$Sprite.play("walk_left")
			direction = FacingDir.Left
		elif round(velocity.x) != 0 and direction == FacingDir.Right:
			if $Sprite.animation != "walk_right":
				$Sprite.stop()
				$Sprite.play("walk_right")
			direction = FacingDir.Right
		else:
			if direction == FacingDir.Left: 
				if $Sprite.is_playing():
					$Sprite.stop()
					$Sprite.play("stand_left")
			if direction == FacingDir.Right:
				if $Sprite.is_playing():
					$Sprite.stop()
					$Sprite.play("stand_right")
	pass