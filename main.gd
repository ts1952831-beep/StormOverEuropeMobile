extends Node3D

# Free prototype: simple procedural city, touch-to-move character, and objective.
# Uses only built-in Godot nodes and meshes; no external assets required.

const MAP_SIZE := 32.0
const MOVE_SPEED := 4.0
const ARRIVAL_DISTANCE := 0.28

var player: CharacterBody3D
var camera: Camera3D
var destination := Vector3(0.0, 0.85, 8.0)
var status_label: Label
var objective: Area3D
var objective_reached := false

func _ready() -> void:
    _make_city()
    _make_player()
    _make_camera()
    _make_ui()
    _make_objective()
    destination = player.global_position
    status_label.text = "MISSÃO 1 — Toca no chão para te moveres"

func _make_city() -> void:
    var ground := StaticBody3D.new()
    ground.name = "Ground"
    add_child(ground)

    var ground_mesh := BoxMesh.new()
    ground_mesh.size = Vector3(MAP_SIZE, 0.2, MAP_SIZE)
    var ground_visual := MeshInstance3D.new()
    ground_visual.mesh = ground_mesh
    ground_visual.position.y = -0.1
    ground_visual.material_override = _mat(Color("#52664b"))
    ground.add_child(ground_visual)

    var ground_collision := CollisionShape3D.new()
    var ground_shape := BoxShape3D.new()
    ground_shape.size = ground_mesh.size
    ground_collision.shape = ground_shape
    ground_collision.position.y = -0.1
    ground.add_child(ground_collision)

    # Roads are visual only, so the player can cross them freely.
    _make_block(Vector3(0, 0.012, 0), Vector3(4.5, 0.025, MAP_SIZE),
        Color("#50545a"), false)
    _make_block(Vector3(0, 0.02, 0), Vector3(MAP_SIZE, 0.03, 4.0),
        Color("#50545a"), false)

    var buildings: Array[Vector3] = [
        Vector3(-8, 0, -8), Vector3(-8, 0, 7),
        Vector3(8, 0, -8), Vector3(8, 0, 7),
        Vector3(-12, 0, 0), Vector3(12, 0, 0),
        Vector3(-5, 0, -12), Vector3(5, 0, 12)
    ]

    for i in range(buildings.size()):
        var h := 2.8 + float(i % 3) * 0.65
        var tint := Color("#b49a7c") if i % 2 == 0 else Color("#8996a3")
        _make_block(buildings[i] + Vector3(0, h * 0.5, 0),
            Vector3(3.0, h, 3.0), tint, true)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-52, -30, 0)
    sun.light_energy = 1.1
    add_child(sun)

    var world_env := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#b8c7d9")
    env.ambient_light_energy = 0.55
    world_env.environment = env
    add_child(world_env)

func _make_block(pos: Vector3, size: Vector3, tint: Color, solid: bool) -> void:
    var root: Node3D
    if solid:
        root = StaticBody3D.new()
    else:
        root = Node3D.new()
    root.position = pos
    add_child(root)

    var mesh := BoxMesh.new()
    mesh.size = size
    var visual := MeshInstance3D.new()
    visual.mesh = mesh
    visual.material_override = _mat(tint)
    root.add_child(visual)

    if solid:
        var collision := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = size
        collision.shape = shape
        root.add_child(collision)

func _make_player() -> void:
    player = CharacterBody3D.new()
    player.name = "Player"
    player.position = Vector3(0, 0.85, 8)
    add_child(player)

    var body_mesh := CapsuleMesh.new()
    body_mesh.radius = 0.38
    body_mesh.height = 1.7
    var body := MeshInstance3D.new()
    body.mesh = body_mesh
    body.material_override = _mat(Color("#2587ff"))
    player.add_child(body)

    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.38
    shape.height = 1.7
    collision.shape = shape
    player.add_child(collision)

func _make_camera() -> void:
    camera = Camera3D.new()
    camera.name = "Camera3D"
    camera.position = Vector3(0, 17, 17)
    add_child(camera)
    camera.look_at(Vector3(0, 0, 0), Vector3.UP)
    camera.current = true
    camera.fov = 55.0

func _make_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)

    status_label = Label.new()
    status_label.position = Vector2(22, 20)
    status_label.add_theme_font_size_override("font_size", 24)
    status_label.add_theme_color_override("font_color", Color.WHITE)
    status_label.add_theme_color_override("font_shadow_color", Color.BLACK)
    status_label.add_theme_constant_override("shadow_offset_x", 2)
    status_label.add_theme_constant_override("shadow_offset_y", 2)
    layer.add_child(status_label)

func _make_objective() -> void:
    objective = Area3D.new()
    objective.name = "MissionObjective"
    objective.position = Vector3(10, 0.4, -10)
    add_child(objective)

    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.85
    mesh.bottom_radius = 0.85
    mesh.height = 0.12
    var visual := MeshInstance3D.new()
    visual.mesh = mesh
    visual.material_override = _mat(Color("#f0c541"))
    objective.add_child(visual)

    var collision := CollisionShape3D.new()
    var shape := CylinderShape3D.new()
    shape.radius = 0.9
    shape.height = 1.5
    collision.shape = shape
    objective.add_child(collision)
    objective.body_entered.connect(_on_objective_body_entered)

func _on_objective_body_entered(body: Node3D) -> void:
    if body == player and not objective_reached:
        objective_reached = true
        status_label.text = "OBJETIVO CONCLUÍDO! — Protótipo 0.1"

func _mat(tint: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    return material

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch and event.pressed:
        _set_destination(event.position)
    elif event is InputEventMouseButton:
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            _set_destination(event.position)

func _set_destination(screen_pos: Vector2) -> void:
    var ray_origin := camera.project_ray_origin(screen_pos)
    var ray_direction := camera.project_ray_normal(screen_pos)
    var ground_plane := Plane(Vector3.UP, 0.0)
    var hit = ground_plane.intersects_ray(ray_origin, ray_direction)
    if hit == null:
        return

    var point: Vector3 = hit
    if absf(point.x) <= MAP_SIZE * 0.5 and absf(point.z) <= MAP_SIZE * 0.5:
        destination = Vector3(point.x, 0.85, point.z)
        if not objective_reached:
            status_label.text = "A deslocar-se..."

func _physics_process(_delta: float) -> void:
    if not is_instance_valid(player):
        return

    var offset := destination - player.global_position
    offset.y = 0.0

    if offset.length() > ARRIVAL_DISTANCE:
        var direction := offset.normalized()
        player.velocity.x = direction.x * MOVE_SPEED
        player.velocity.z = direction.z * MOVE_SPEED
        player.move_and_slide()
        if not objective_reached:
            status_label.text = "A explorar a cidade"
    else:
        player.velocity.x = 0.0
        player.velocity.z = 0.0
        player.move_and_slide()
        if not objective_reached:
            status_label.text = "MISSÃO 1 — Vai até ao marcador amarelo"
