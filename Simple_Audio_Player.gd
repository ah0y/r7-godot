extends Spatial

var audio_pistol_shot = preload("res://assets/gun_revolver_pistol_shot_04.wav")
var audio_gun_cock = preload("res://assets/gun_semi_auto_rifle_cock_02.wav")
var audio_rifle_shot = preload("res://assets/gun_rifle_sniper_shot_01.wav")

var audio_node = null

func _ready():
	audio_node = $Audio_Stream_Player
	audio_node.connect("finished", self, "destroy_self")
	audio_node.stop()
	
func play_sound(sound_name, position=null):
	
	if audio_pistol_shot == null or audio_rifle_shot == null or audio_gun_cock == null:
		print ("Audio not set!")
		queue_free()
		return
	if sound_name == "Pistol_shot":
		audio_node.stream = audio_pistol_shot
	elif sound_name == "Rifle_shot":
		audio_node.stream = audio_rifle_shot
	elif sound_name == "Gun_cock":
		audio_node.stream = audio_gun_cock
	else:
		print ("UNKNOWN STREAM")
		queue_free()
		return
	
	if audio_node is AudioStreamPlayer3D:
		if position != null:
			audio_node.global_transform.origin = position
			
	audio_node.play()
	
func destroy_self():
	audio_node.stop()
	queue_free()
