extends Spatial

# Vars
onready var RayCastCheck = get_node("RayCast")

# Called when entity enters player vision
func EnterVision():
	# Prepares check and sets it to player voice
	var PlayerPosition = RayCastCheck.to_local(PlayerData.player_saved_position)
	RayCastCheck.set_cast_to(PlayerPosition)
	yield(get_tree().create_timer(0.1), "timeout")
	
	# While colliding, constantly update raycast position and check if colliding with player
	var IsColliding = true
	while IsColliding == true:
		# Update to player position
		PlayerPosition = RayCastCheck.to_local(PlayerData.player_saved_position)
		RayCastCheck.set_cast_to(PlayerPosition)
		
		# Check if its not "StaticBody"
		if RayCastCheck.get_collider() == null:
			print("Collider null. Skipping check")
		elif RayCastCheck.get_collider().get_name() == "player":
			print("Entity detected player. Disappearing")
			IsColliding = false
		
		yield(get_tree(), "idle_frame")
	
	# Gets rid of entity
	print("Entity entered player vision")
	yield(get_tree().create_timer(0.5), "timeout")
	queue_free()
