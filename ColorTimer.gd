extends Timer


signal color_change(number)

var base_mesh = "Turret/Turret_Base"

#func _input(event):
#    if event is InputEventMouseButton:
#        if event.button_index == BUTTON_LEFT and event.pressed:
#            emit_signal("shoot", Bullet, rotation, position)

func timeout():
	emit_signal("color_change", 1)
