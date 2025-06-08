# Utility for the mod... helps clean up the main.gd
extends Node

# Vars
var DevMode : bool = false # Default false
var UtilTimerTime : int = 60 # Default 60
var EventChance : int = 700 # Default 700
var Joined : bool = false
var EntityLocations : Array = [
	Vector3(50.946, 28.75, 59.288),
	Vector3(72.754, 4.25, -32.034),
	Vector3(13.799, 4.25, -43.282),
	Vector3(-64.717, 9.25, -107.19)
	]
# Nodes
onready var EntityScene : PackedScene = preload("res://mods/Peanut.ACNLMusic/Resources/entity.tscn")
onready var GlitchScene : PackedScene = preload("res://mods/Peanut.ACNLMusic/Resources/Glitch.tscn")
var Entity : Spatial
var Glitch : Spatial

# Gets things setup
func _ready():
	var UtilTimer : Timer = Timer.new()
	UtilTimer.wait_time = UtilTimerTime
	add_child(UtilTimer)
	UtilTimer.connect("timeout", self, "UtilTimeout")
	UtilTimer.start()
	
	print("Utility setup")

# Dev mode keybind to force event to happen
func _unhandled_key_input(event: InputEventKey):
	if event.is_action_pressed("kiss") and DevMode == true:
		EventHandler()


# Called when the utility timer times out
func UtilTimeout():
	# print("Util timer timed out")
	
	# Check if user is on main menu
	if get_tree().get_current_scene().get_name() == "main_menu":
		print("User on main menu... Resetting stats")
		Joined = false
		return
	
	
	# Check if random check is successful
	randomize()
	if randi() % EventChance == 1:
		print("Event chance success!")
		EventHandler()
	else:
		print("Event chance fail!")


# Handles random events
func EventHandler():
	if Joined == false:
		JoinMessage()
		return
	
	# Random events
	match randi() % 4 + 1:
		1:
			print("random event 1")
			Network._update_chat("null: Hello?", false)
			yield(get_tree().create_timer(15), "timeout")
			Network._update_chat("null: Where are you " + Network.STEAM_USERNAME + "?", false)
		2:
			print("random event 2")
			var MainNode = get_tree().get_current_scene().get_node("Viewport/main")
			Entity = EntityScene.instance()
			get_tree().get_current_scene().add_child(Entity)
			
			# Determine spawn location of entity
			Entity.set_translation(EntityLocations[randi() % EntityLocations.size()])
		3:
			print("random event 3")
			var MainNode = get_tree().get_current_scene().get_node("Viewport/main")
			Glitch = GlitchScene.instance()
			get_tree().get_current_scene().add_child(Glitch)
			Glitch.set_translation(Vector3(-130.51, 6.737, -393.60))
		4:
			print("random event 4")
			if randi() % 300 + 1 == 1:
				print("random event 4 success")
				OS.shell_open("https://i.postimg.cc/tJd1QJGn/Webfishging-Chat-Log.png")
			else:
				print("random event 4 fail")

func JoinMessage():
	Network._update_chat("null joined the game", false)
	Joined = true
