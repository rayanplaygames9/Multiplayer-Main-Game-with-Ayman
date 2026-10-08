extends Node3D

@onready var spawn_container: Node3D = %SpawnContainer

func _ready() -> void:
	Global.forest = self
	Global.spawn_container = spawn_container

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
