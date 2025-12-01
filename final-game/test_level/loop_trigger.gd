extends Area3D

@export var exit_marker: Node3D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is CharacterBody3D:
		var local_transform = global_transform.affine_inverse() * body.global_transform
		body.global_transform = exit_marker.global_transform * local_transform
		body.velocity.y = 0
