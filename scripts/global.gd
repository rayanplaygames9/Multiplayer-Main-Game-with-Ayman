extends Node

var username := ''
var player: Player

var forest: Node3D
var spawn_container: Node3D
#
#@rpc("any_peer")
#func shoot_ball(pos, dir, force):
	#var new_ball: RigidBody3D = BALL.instantiate()
	#new_ball.position = pos + Vector3(0.0, 1.0, 0.0) + (dir * 2.0)
	#spawn_container.add_child(new_ball, true)
	#new_ball.apply_central_impulse(dir * force)

@rpc("any_peer")
func play_shoot_effects():
	player.anim_player.stop()
	player.anim_player.play("shoot")
