extends CharacterBody3D
class_name Player

@export var sensitivity: float = 0.005

const SPEED = 10.0
const JUMP_VELOCITY = 10.0
const GRAVITY = 30.0

@onready var anim_player: AnimationPlayer = $AnimationPlayer

@onready var camera_3d: Camera3D = %Camera3D
@onready var head: Node3D = %Head
@onready var nameplate: Label3D = %Nameplate

@onready var menu: Control = %Menu
@onready var button_leave: Button = %ButtonLeave
@onready var label_session: Label = %LabelSession
@onready var button_copy_session: Button = %ButtonCopySession
@onready var muzzle_flash: GPUParticles3D = $Head/Camera3D/Pistol/MuzzleFlash

func _enter_tree() -> void:
	set_multiplayer_authority(int(name))

func _ready():
	menu.hide()
	add_to_group("Players")
	nameplate.text = name
	
	if not is_multiplayer_authority():
		set_process(false)
		set_physics_process(false)
		return
	
	if Global.username: nameplate.text = Global.username
	
	label_session.text = Network.tube_client.session_id
	camera_3d.current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	button_leave.pressed.connect(func(): Network.leave_server())
	button_copy_session.pressed.connect(func(): DisplayServer.clipboard_set(Network.tube_client.session_id))
	DisplayServer.clipboard_set(Network.tube_client.session_id)

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)	
		camera_3d.rotate_x(-event.relative.y * sensitivity)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-90), deg_to_rad(90))

	if event is InputEventScreenDrag:
		head.rotate_y(-event.relative.x * sensitivity)
		camera_3d.rotate_x(-event.relative.y * sensitivity)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-90), deg_to_rad(90))

	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('menu') and menu.visible == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		menu.show()
	elif Input.is_action_just_pressed('menu') and menu.visible == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		menu.hide()

	if Input.is_action_just_pressed('shoot'):
		play_shoot_effects()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if anim_player.current_animation == "shoot":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		anim_player.play("move_pistol")
	else:
		anim_player.play("idle_pistol")

	move_and_slide()
	
#func shoot():
	#var facing_dir = -head.transform.basis.z
	#var force = 100
	#var pos = global_position
	#Global.shoot_ball.rpc_id(1, pos, facing_dir, force)

func play_shoot_effects():
	anim_player.stop()
	anim_player.play("shoot_pistol")
	muzzle_flash.restart()
	muzzle_flash.emitting = true
