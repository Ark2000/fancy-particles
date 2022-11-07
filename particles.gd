@tool
extends Control

@export var max_points = 60
@export var fade_time = 2.0
@export var max_line_length = 160.0
@export var interact_intension = 3000.0
@export var min_radius = 0.5
@export var max_radius = 3.0
@export var min_velocity = 20.0
@export var max_velocity = 60.0
@export var point_color = Color.RED
@export var line_color = Color.WHITE

var points = []

class Po:
	var position
	var velocity
	var radius
	var life
	var velocity2

func _ready() -> void:
	for i in range(max_points):
		points.push_back(reset_po(Po.new()))


func reset_po(po:Po) -> void:
	var radius = get_rect()
	po.position = Vector2(randf() * radius.size.x, randf() * radius.size.y)
	po.velocity = Vector2.RIGHT.rotated(randf() * TAU) * randf_range(min_velocity, max_velocity)
	po.radius = randf_range(min_radius, max_radius)
	po.life = 0.0
	po.velocity2 = Vector2.ZERO
	return po

func _physics_process(delta) -> void:
	for po in points:
		if !get_rect().has_point(po.position):
			po.life -= delta
			if po.life < 0.0:
				reset_po(po)
		else:
			po.life = min(po.life + delta, fade_time)
		po.position += (po.velocity + po.velocity2) * delta
	if points.size() > 0:
		points[0].position = get_local_mouse_position()
	queue_redraw()

#thanks reddit user ualac for his improvement of _draw() function which halve the calcuation
#and according to others, this can be further optimized by using compute shader in GodotV4 or physics server etc.
#see the reddit post below:
#https://www.reddit.com/r/godot/comments/x2fo0n/a_fancy_background_effect_inspired_by_some_web/
func _draw() -> void :
	var pMousePos : Vector2 = points[0].position
	var pA : Po
	var pB : Po
	var pColor : Color
	var lColor : Color
	for a in range( points.size() ) :
		pA = points[a]
		# do certain functions for every point
		pColor = point_color
		pColor.a = pA.life / fade_time
		draw_circle(pA.position, pA.radius, pColor)
		# update point velocity with the mouse position
		var mouse_dist = pA.position.distance_to(pMousePos)
		if mouse_dist < max_line_length and a != 0 :
			pA.velocity2 = (pA.position - pMousePos).normalized() * (1.0 / mouse_dist) * interact_intension
		else :
			pA.velocity2 = Vector2.ZERO
		# check for valid second point
		for b in range( points.size() ) :
			if a <= b :
				continue
			# this is a valid pair of points (ie. a line)
			pB = points[b]
			# draw lines if points are close enough
			var distance = pA.position.distance_to(pB.position)
			if distance < max_line_length:
				lColor = line_color
				lColor.a = (1.0 - distance / max_line_length) * min( pA.life, pB.life) / fade_time
				draw_line(pA.position, pB.position, lColor, 2.0 * (1.0 - distance / max_line_length))
