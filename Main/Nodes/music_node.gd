extends Node

signal on_beat

#var nocturnal_pulse = preload("res://OST/Nocturnal_Pulse.mp3")
var track_tweener 

var nocturnal_pulse_beat_1 = preload("res://OST/NocturnalPulse/Beat1.mp3") #TrackLEFT
var nocturnal_pulse_synth = preload("res://OST/NocturnalPulse/Synthetizer.mp3") #TrackLEFT
var nocturnal_pulse_beat_2 = preload("res://OST/NocturnalPulse/Beat2.mp3") #Main!!
var nocturnal_pulse_aux_beat = preload("res://OST/NocturnalPulse/AuxBeat.mp3") #TrackRight
var nocturnal_pulse_bass = preload("res://OST/NocturnalPulse/Bass.mp3") #TrackRight

var wingbeat_prelude_percussion = preload("res://OST/WingbeatPrelude/Percussion.mp3") #TrackLeft
var wingbeat_prelude_piano = preload("res://OST/WingbeatPrelude/Piano.mp3") #TrackLeft
var wingbeat_prelude_beat = preload("res://OST/WingbeatPrelude/Beat.mp3") #Main
var wingbeat_prelude_synth = preload("res://OST/WingbeatPrelude/Synth-_1_.mp3") #TrackRight
var wingbeat_prelude_bass = preload("res://OST/WingbeatPrelude/BassLine.mp3") #TrackRight

var dripstone_bass = preload("res://OST/dripstoneSonata/Bass.mp3") #TrackLeft
var dripstone_percussion = preload("res://OST/dripstoneSonata/Percussion.mp3") #TrackLeft
var dripstone_beat = preload("res://OST/dripstoneSonata/MainBeat.mp3") #Main
var dripstone_misc = preload("res://OST/dripstoneSonata/Myscellaneoous.mp3") #TrackRight
var dripstone_synth = preload("res://OST/dripstoneSonata/Synth.mp3") #TrackRight

var showcase_tweneer
var showcase_beat_tweeer
var in_showcase_animation = true

var current_track_lenghts_array = [0.0, 0.0, 0.0]
var current_track_length

func play_ost(TRACK_ID = 0, reset = false) -> void:
	if reset:
		current_track_length = 0
	else:
		current_track_length = %MainLayerStreamPlayer.get_playback_position()
		
	match TRACK_ID:
		0:
			%songTitle.text = "Nocturnal pulse"
			$Node.bpm = 128
			set_tracks(nocturnal_pulse_beat_2, nocturnal_pulse_synth, nocturnal_pulse_beat_1, nocturnal_pulse_aux_beat, nocturnal_pulse_bass)
		1:
			%songTitle.text = "Wingbeat"
			$Node.bpm = 128
			set_tracks(wingbeat_prelude_beat, wingbeat_prelude_percussion, wingbeat_prelude_piano, wingbeat_prelude_synth, wingbeat_prelude_bass)
		2:
			%songTitle.text = "Dripstone"
			$Node.bpm = 150
			set_tracks(dripstone_bass, dripstone_percussion, dripstone_beat, dripstone_misc, dripstone_synth)
	%MainLayerStreamPlayer.call_deferred("play", current_track_length)
	%TrackLeft1.call_deferred("play", current_track_length)
	%TrackLeft2.call_deferred("play", current_track_length)
	%TrackRight1.call_deferred("play", current_track_length)
	%TrackRight2.call_deferred("play", current_track_length)
	showcase_song_info()

func set_tracks(main_track, l1track, l2track, r1track, r2track) -> void:
	%MainLayerStreamPlayer.set_deferred("stream", main_track)
	%TrackLeft1.set_deferred("stream", l1track)
	%TrackLeft2.set_deferred("stream", l2track)
	%TrackRight1.set_deferred("stream", r1track)
	%TrackRight2.set_deferred("stream", r2track)

func cave_transition() -> void:
	await on_beat
	tween_tracks(-60, -60, -60, -60)
	await on_beat
	await on_beat
	await on_beat
	play_ost(2)
	tween_tracks(-3, -3, -3, -3)

func exit_cave_transition() -> void:
	await on_beat
	tween_tracks(-60, -60, -60, -60)
	await on_beat
	await on_beat
	await on_beat
	play_ost(randi_range(0,1))
	tween_tracks(-3, -3, -3, -3)
	
func tween_tracks(trackl1db = 0, trackl2db = 0, trackr1db = 0, trackr2db = 0, duration = 1) -> void:
	if track_tweener:
		track_tweener.kill()
	track_tweener = create_tween().set_parallel()
	track_tweener.tween_property(%TrackLeft1, "volume_db", trackl1db, duration)
	track_tweener.tween_property(%TrackLeft2, "volume_db", trackl2db, duration)
	track_tweener.tween_property(%TrackRight1, "volume_db", trackr1db, duration)
	track_tweener.tween_property(%TrackRight2, "volume_db", trackr2db, duration)
	
func _on_node_beat(current_beat: int) -> void:
	on_beat.emit()
	if in_showcase_animation:
		if showcase_beat_tweeer:
			showcase_beat_tweeer.kill()
		showcase_beat_tweeer = create_tween().set_parallel()
		showcase_beat_tweeer.tween_property(%songTitle, "scale", Vector2(1.1, 1.1), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		showcase_beat_tweeer.tween_property(%songAuthor, "scale", Vector2(1.3, 1.3), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		showcase_beat_tweeer.chain().tween_property(%songTitle, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		showcase_beat_tweeer.tween_property(%songAuthor, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

func showcase_song_info() -> void:
	%songShowcaseControl.position.y = 360
	%songShowcaseControl.modulate.a = 0
	if showcase_tweneer:
		showcase_tweneer.kill()
	showcase_tweneer = create_tween()
	showcase_tweneer.tween_property(%songShowcaseControl, "position:y", 200, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	showcase_tweneer.parallel().tween_property(%songShowcaseControl, "modulate:a", 1, 1)
	showcase_tweneer.tween_property(%songShowcaseControl, "position:y", 160, 2)
	showcase_tweneer.tween_property(%songShowcaseControl, "position:y", 0, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	showcase_tweneer.parallel().tween_property(%songShowcaseControl, "modulate:a", 0, 1)

func stop()-> void:
	%TrackLeft1.stop()
	%TrackLeft2.stop()
	%TrackRight1.stop()
	%TrackRight2.stop()
