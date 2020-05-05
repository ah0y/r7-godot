extends Spatial

export (bool) var use_raycast = false

const TURRET_DAMAGE_BULLET = 20
const TURRET_DAMAGE_RAYCAST = 5

const FLASH_TIME = 0.1
var flash_timer = 0

const FIRE_TIME = 0.8
var fire_timer = 0

var node_turret_head = null
var node_raycast = null
var node_flash_one = null
var node_flash_two = null

var ammo_in_turret = 20
const AMMO_IN_FULL_TURRET = 20
const AMMO_RELOAD_TIME = 4
var ammo_reload_timer = 0

var current_target = null

var is_active = false

const PLAYER_HEIGHT = 3
var smoke_particiles

var turret_health = 60
const MAX_TURRET_HEALTH = 60

const DESTROYED_TIME = 20
var destroyed_timer = 0

var bullet_scene = preload("Bullet_Scene.tscn")

var base_mesh 
var head_mesh

const COLOR_TO_HEX = {"RED": "FF0000", "ORANGE": "FF7F00", "YELLOW": "FFFF00", "GREEN": "00FF00", "BLUE": "0000FF", "INDIGO": "2E2B5F", "VIOLET": "8B00FF"}
const COLOR_TO_NUMBER = {"RED": 0, "ORANGE": 1, "YELLOW": 2, "GREEN": 3, "BLUE": 4, "INDIGO": 5, "VIOLET": 6}
const HEX_TO_COLOR = {"FF0000": "RED", "FF7F00": "ORANGE", "FFFF00": "YELLOW", "00FF00": "GREEN", "0000FF":"BLUE", "2E2B5F": "INDIGO", "8B00FF": "VIOLET"}
const NUMBER_TO_COLOR = {0:"RED", 1: "ORANGE", 2: "YELLOW", 3: "GREEN", 4: "BLUE", 5: "INDIGO", 6: "VIOLET"}

func _ready():
	
	$Vision_Area.connect("body_entered", self, "body_entered_vision")
	$Vision_Area.connect("body_exited", self, "body_exited_vision")
	$ColorTimer.connect("timeout", self, "change_color")
	
	base_mesh = $Base/Turret_Base
	head_mesh = $Head/Turret_Head
	
	node_turret_head = $Head 
	node_raycast = $Head/Ray_Cast
	node_flash_one = $Head/Flash 
	node_flash_two = $Head/Flash_2

	node_raycast.add_exception(self)
	node_raycast.add_exception($Base/Static_Body)
	node_raycast.add_exception($Head/Static_Body)
	node_raycast.add_exception($Vision_Area)
	
	node_flash_one.visible = false 
	node_flash_two.visible = false
	
	smoke_particiles = $Smoke 
	smoke_particiles.emitting = false 
	
	turret_health = MAX_TURRET_HEALTH
	
func _physics_process(delta):
	if is_active == true:
		if flash_timer > 0:
			flash_timer -= delta 
			
			if flash_timer <= 0:
				node_flash_one.visible = false 
				node_flash_two.visible = false
				
		if current_target != null:
			node_turret_head.look_at(current_target.global_transform.origin + Vector3(0, PLAYER_HEIGHT, 0), Vector3(0,1,0))
			
			if turret_health > 0:
				if ammo_in_turret > 0:
					if fire_timer > 0:
						fire_timer -= delta
					else:
						fire_bullet()
				else: 
					if ammo_reload_timer > 0:
						ammo_reload_timer -= delta
					else:
						ammo_in_turret = AMMO_IN_FULL_TURRET
						
	if turret_health <= 0:
		if destroyed_timer > 0:
			destroyed_timer -= delta
		else:
			turret_health = MAX_TURRET_HEALTH 
			smoke_particiles.emitting = false 

func fire_bullet():
	if use_raycast == true:
		node_raycast.look_at(current_target.global_transform.origin + Vector3(0, PLAYER_HEIGHT, 0), Vector3(0,1,0))
		
		node_raycast.force_raycast_update()
		
		if node_raycast.is_colliding():
			var body = node_raycast.get_collider()
			if body.has_method("bullet_hit"):
				body.bullet_hit(TURRET_DAMAGE_RAYCAST, node_raycast.get_collision_point())
				
		ammo_in_turret -= 1
		
	else:
		var clone = bullet_scene.instance()
		var scene_root = get_tree().root.get_children()[0]
		scene_root.add_child(clone)
		
		clone.global_transform = $Head/Barrel_End.global_transform
		clone.scale = Vector3(8,8,8)
		clone.BULLET_DAMAGE = TURRET_DAMAGE_BULLET 
		clone.BULLET_SPEED = 60
		
		ammo_in_turret -= 1
		
	node_flash_one.visible = true
	node_flash_two.visible = true 
	
	flash_timer = FLASH_TIME
	fire_timer = FIRE_TIME 
	
	if ammo_in_turret <= 0:
		ammo_reload_timer = AMMO_RELOAD_TIME
		
func body_entered_vision(body):
	if current_target == null:
		if body is KinematicBody:
			current_target = body
			is_active = true 
			
func body_exited_vision(body):
	if current_target != null:
		if body == current_target:
			current_target = null 
			is_active = false 
			
			flash_timer = 0
			fire_timer = 0
			node_flash_one.visible = false 
			node_flash_two.visible = false 
			
func bullet_hit(damage, bullet_hit_pos):
	turret_health -= damage
	
	if turret_health <= 0:
		smoke_particiles.emitting = true 
		destroyed_timer = DESTROYED_TIME
		
func change_color():
	var turret_material = base_mesh.get_surface_material(0)
	var turret_color = turret_material.albedo_color
	var current_color = HEX_TO_COLOR[turret_material.albedo_color.to_html(false).to_upper()]
	var color_number_to_exclude = COLOR_TO_NUMBER[current_color]
	var possible_colors = [1,2,3,4,5,6]
	possible_colors.erase(color_number_to_exclude)
	possible_colors.shuffle()
	var new_color = possible_colors.pop_front()
	new_color = NUMBER_TO_COLOR[new_color]
	turret_material.albedo_color = Color(COLOR_TO_HEX[new_color])
	base_mesh.set_surface_material(0, turret_material)
	base_mesh.set_surface_material(1, turret_material)
	base_mesh.set_surface_material(2, turret_material)
	base_mesh.set_surface_material(3, turret_material)


	var head_material = head_mesh.get_surface_material(0)
	var head_color = head_material.albedo_color
	head_material.albedo_color = Color(COLOR_TO_HEX[new_color])
	head_mesh.set_surface_material(0, head_material)
	head_mesh.set_surface_material(1, head_material)
	head_mesh.set_surface_material(2, head_material)
	head_mesh.set_surface_material(3, head_material)		
