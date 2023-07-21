class_name Bullet
extends Node

var shape_id : RID
var movement_vector : Vector2
var current_position : Vector2
var lifetime : float = 0.0
var damage : float = 75.0
var animation_lifetime : float = 0.0
var image_offset : int = 0
var layer : String = "front"
var speed: float = 600.0
var faction: String = "fleet_1"

func is_bullet():
	print("checked bullet")
	return true
