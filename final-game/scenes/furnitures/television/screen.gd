extends MeshInstance3D

@export var video_path := "res://assets/videos/video_only.ogv"
@export var auto_play := true
@export var loop := true

var video_player: VideoStreamPlayer

func _ready() -> void:
	# Create a hidden canvas layer for the video player
	var hidden_layer = CanvasLayer.new()
	hidden_layer.layer = -100  # Put it on a layer that won't be seen
	hidden_layer.visible = false
	add_child(hidden_layer)
	# this is comment
	
	# --- Create video player (decoder) ---
	video_player = VideoStreamPlayer.new()
	video_player = VideoStreamPlayer.new()
	video_player.loop = loop
	video_player.top_level = true  # Detach from parent transform
	video_player.hide()  # Use hide() instead of visible = false
	add_child(video_player)
	
	
	var stream := load(video_path)
	if not stream:
		push_error("Failed to load video: " + video_path)
		return
	video_player.stream = stream
	
	# ... rest of your code stays the same
	
	
	# --- Create TV screen mesh ---
	var quad := QuadMesh.new()
	quad.size = Vector2(1.6, 0.9) # 16:9 screen
	mesh = quad
	
	# --- Create physical material (NOT UI-flat) ---
	var mat := StandardMaterial3D.new()
	var video_tex := video_player.get_video_texture()
	
	mat.albedo_texture = video_tex
	
	# Slight emission so it glows like a screen (but not UI)
	mat.emission_enabled = true
	mat.emission_texture = video_tex
	mat.emission_energy_multiplier = 0.25
	
	# IMPORTANT: use lit shading so it feels in-world
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	mat.roughness = 0.4
	mat.specular = 0.5
	
	# Fix upside-down video
	mat.uv1_scale = Vector3(1, -1, 1)
	mat.uv1_offset = Vector3(0, 1, 0)
	
	set_surface_override_material(0, mat)
	
	# --- Play ---
	if auto_play:
		await get_tree().process_frame
		video_player.play()

# --- Controls ---
func play() -> void:
	if video_player:
		video_player.play()

func pause() -> void:
	if video_player:
		video_player.paused = !video_player.paused

func stop() -> void:
	if video_player:
		video_player.stop()
