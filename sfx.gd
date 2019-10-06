extends TextureButton

func _on_Music_toggled(button_pressed):
	AudioServer.set_bus_mute(2, button_pressed)