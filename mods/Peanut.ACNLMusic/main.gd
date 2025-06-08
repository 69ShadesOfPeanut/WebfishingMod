extends Node

# Vars
var MusicCheckTime : int = 5
var KKSliderArray : Array
var time : Dictionary
var hour
var minute
var CurrentSong
var SongCheckCount : int = 0
var KKHours : Array = ["20", "21", "22", "23", "0", "1", "2"]
onready var utility = preload("res://mods/Peanut.ACNLMusic/utility.gd").new()

# Create child nodes of global audio for each track
# Set correct stream for audio stream player node
func _ready():
	# Add "utility" script as child
	add_child(utility)
	
	print("Setting up audio...")
	
	# Loops per song track
	for i in range (0, 24):
		var ist = str(i)
		
		# Adds songs to song list dic
		GlobalAudio.song_volumes[ist] = - 15
		
		
		# Create audio stream players for each song and assign names and values
		var Music = AudioStreamPlayer.new()
		var Stream = load("res://mods/Peanut.ACNLMusic/Resources/Audio/" + ist + ".mp3")
		Music.stream = Stream
		Music.name = ist
		Music.bus = "Music"
		GlobalAudio.add_child(Music)
	
	
	KKArraySetup()
	# Add audio stream player to control KK Slider songs
	var KKSliderMusic = AudioStreamPlayer.new()
	KKSliderMusic.name = "KKSliderMusic"
	KKSliderMusic.bus = "Music"
	GlobalAudio.add_child(KKSliderMusic)
	GlobalAudio.song_volumes["KKSliderMusic"] = 0
	
	
	# Setup how often music is checked. Default is 1 second
	var MusicCheck = Timer.new()
	MusicCheck.wait_time = MusicCheckTime
	GlobalAudio.add_child(MusicCheck)
	MusicCheck.connect("timeout", self, "TimeoutCalled")
	MusicCheck.start()
	
	# Sets up menu music
	print("Music check disabled. Starting main menu music")
	GlobalAudio.song_volumes["menu"] = - 15
	
	var Music = AudioStreamPlayer.new()
	var MenuMusic = load("res://mods/Peanut.ACNLMusic/Resources/Audio/Main.mp3")
	Music.stream = MenuMusic
	Music.name = "menu"
	Music.bus = "Music"
	GlobalAudio.add_child(Music)


# Called whenever music check timer is done
func TimeoutCalled():
	# Debug line
	#print(GlobalAudio.song_playing)
	
	# Set current hour
	time = Time.get_time_dict_from_system()
	hour = str(time["hour"])
	minute = str(time["minute"])
	
	# Check if hour is KK Slider time
	if KKSliderTime() == true and get_tree().get_current_scene().get_name() == "world":
		# Check if KK slider song is playing
		if GlobalAudio.get_node("KKSliderMusic").is_playing() == true:
			#print("KK Slider playing")
			return
		print("KK Slider time!")
		
		# Select random song
		randomize()
		var RandomKKSong = KKSliderArray[randi() % KKSliderArray.size()]
		print(RandomKKSong)
		# Setup song node
		var KKSliderMusicNode = GlobalAudio.get_node("KKSliderMusic")
		var KKSliderSong = load("res://mods/Peanut.ACNLMusic/Resources/KKSlider/" + RandomKKSong)
		KKSliderMusicNode.stream = KKSliderSong
		yield(get_tree().create_timer(2), "timeout")
		GlobalAudio._play_music("KKSliderMusic")
		return
	
	# Check if song is playing
	if get_tree().get_current_scene().get_name() == "world" and GlobalAudio._is_song_playing() == false:
		# Check the last set song
		# This is cause during song transitions songs are set as "null"
		if CurrentSong == hour and GlobalAudio._is_song_playing() == false:
			# Check a total of 5 times as after current song is set and player leaves and joins another lobby
			# it can flag it as already playing...
			if SongCheckCount < 5:
				print("Current song is right one")
				SongCheckCount += 1
				return
		SongCheckCount = 0
		print("Song not playing.... Starting song...")
		
		# Set music playing
		GlobalAudio._play_music(hour)
		CurrentSong = hour
		
		print("Song started")
	# Check if song matches hour
	elif get_tree().get_current_scene().get_name() == "world" and GlobalAudio.song_playing.name != hour:
		print("Song doesn't match hour... Changing song...")
		
		# Change song and set it to the last changed song
		GlobalAudio._play_music(hour)
		CurrentSong = hour
		
		print("Song changed")
	# Checks if on main menu then disabled check and sets up main menu music
	elif get_tree().get_current_scene().get_name() == "main_menu":
		if get_tree().get_current_scene().get_node("world/music_check").is_stopped() == false:
			print("Music check on main menu not disabled, disabling...")
			get_tree().get_current_scene().get_node("world/music_check").stop()
			
			# Plays music after 2 seconds
			yield(get_tree().create_timer(2), "timeout")
			GlobalAudio._play_music("menu")
	
	# Debug line
	#print(GlobalAudio.song_playing)


# Check if KK slider time is current
# returns true if it is KK time
# returns false if it isn't
func KKSliderTime():
	var DateTime = Time.get_date_dict_from_system()
	var Weekday = DateTime["weekday"]
	
	if Weekday == 6:
		if KKHours.has(hour):
			return true
	return false

# Function for setting up KK Slider array
func KKArraySetup():
	# Make array of KK Slider songs
	# Takes files from the KK Slider directory that end in .mp3
	var dir = Directory.new()
	if dir.open("res://mods/Peanut.ACNLMusic/Resources/KKSlider/") == OK:
		print("KK Slider directory opened")
		dir.list_dir_begin()
		var FileName = dir.get_next()
		while FileName != "":
			if (FileName.get_extension() == "import"):
				FileName = FileName.replace(".import", "")
				print("Found file: " + FileName)
				KKSliderArray.append(FileName)
			FileName = dir.get_next()
	else:
		print("An error occured when trying to access KK Slider songs")
	print(KKSliderArray)
