extends Node

# Vars
var MusicCheckTime : int = 1
var time : Dictionary
var hour
var CurrentSong
var SongCheckCount : int = 0

# Create child nodes of global audio for each track
# Set correct stream for audio stream player node
func _ready():
	print("Setting up audio...")
	
	# Loops per song track
	for i in range (0, 24):
		var ist = str(i)
		
		# Adds songs to song list dic
		GlobalAudio.song_volumes[ist] = - 2
		
		
		# Create audio stream players for each song and assign names and values
		var Music = AudioStreamPlayer.new()
		var Stream = load("res://mods/Peanut.ACNLMusic/Resources/Audio/" + ist + ".mp3")
		Music.stream = Stream
		Music.name = ist
		Music.bus = "Music"
		GlobalAudio.add_child(Music)
	
	
	# Setup how often music is checked. Default is 1 second
	var MusicCheck = Timer.new()
	MusicCheck.wait_time = MusicCheckTime
	GlobalAudio.add_child(MusicCheck)
	MusicCheck.connect("timeout", self, "TimeoutCalled")
	MusicCheck.start()


# Called whenever music check timer is done
func TimeoutCalled():
	# Debug line
	#print(GlobalAudio.song_playing)
	
	# Set current hour
	time = Time.get_time_dict_from_system()
	hour = str(time["hour"])
	#print(hour)
	
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
	
	# Debug line
	#print(GlobalAudio.song_playing)
