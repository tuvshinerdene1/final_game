extends SpotLight3D


@onready var flashlight_ray = $RayCast3D

func _process(_delta):
	if flashlight_ray.is_colliding():
		var hit_object = flashlight_ray.get_collider()
		
		# Check if the object hit is part of a Portrait
		# We look at the parent because the script is on the Node3D root of the portrait
		var portrait = hit_object.get_parent() 
		
		if portrait.is_in_group("portraits") and portrait.has_method("shine_light"):
			portrait.shine_light()
	else:
		# Optional: Reset portraits when looking away? 
		# You would need a reference to the last hit portrait to do this.
		pass
