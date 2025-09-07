extends Control


@onready var mod_image_texture: TextureRect = %TextureRect
@onready var mod_name_label: Label = %Name
@onready var author_name_label: Label = %Author
@onready var source: Label = %Source

@onready var loadunload: Button = $Panel/BoxContainer/BoxContainer/loadunload

# Move up and Down Buttons
@onready var moveup: Button = $Panel/BoxContainer/BoxContainer/moveup
@onready var movedown: Button = $Panel/BoxContainer/BoxContainer/movedown
@onready var buttonscontainer: BoxContainer = $Panel/BoxContainer/BoxContainer



const MOD_IMAGE = preload("uid://cndqiyq327n41")

var mod_name = ""
var author_name = ""
var picture_path = ""
var isLocalMod: bool = false
var mod_path = ""
var mod_realPath = "" # This one only Exists for Linux
var loaded: bool = false
var mod_ID: String = ""

var enabledParent: Control
var disabledParent: Control

var enabledIDX: int = 0
var disabledIDX: int = 0

var greyscale: bool = true
var greyscaleShader: Material

var quicksort: bool = false

# Dragging Variables
var dragging: bool = false
var draggable: bool = false
var offset: Vector2

func construct(pic: Texture2D, modname: String, authorname: String, isLocal: bool, path: String = "", modID = "") -> void:
	disabledIDX = get_index()
	# Mod Picture
	mod_image_texture.texture = pic
	if mod_image_texture.texture == null:
		mod_image_texture.texture = MOD_IMAGE
	# Mod Name
	mod_name = modname
	mod_name_label.text = modname
	name = modname
	# Mod Author
	author_name = authorname
	author_name_label.text = "Author: {0}".format([authorname])
	# Is Local
	isLocalMod = isLocal
	if isLocal:
		mod_name_label.text = path.split("/", false)[-1]
		name = path.split("/", false)[-1]
		source.text = "Local"
		$openinsteam.visible = false
	else:
		source.text = "Workshop"

	# Fix the Path because there is a random Newline in it
	mod_path = path
	if !isLocal:
		if path.split("\n").size() > 1:
			mod_path = path.split("\n")[0] + path.split("\n")[1]
	mod_ID = modID
	greyscaleShader = load("res://Assets/Shaders/greyscaleMaterial.tres")
	mod_image_texture.material = greyscaleShader

	add_to_group("mods")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shift"):
		quicksort = true
		moveup.text = "Move to Top"
		moveup.tooltip_text = "Move to the Top of the Load Order (Loads First)"
		movedown.text = "Move to Bottom"
		movedown.tooltip_text = "Move to the Bottom of the Load Order (Loads Last)"
	if event.is_action_released("shift"):
		quicksort = false
		moveup.text = "Move Up"
		moveup.tooltip_text = "Move Up in the Load order"
		movedown.text = "Move Down"
		movedown.tooltip_text = "Move Down in the Load order"

func _on_folder_open_pressed() -> void:
	if ffglobals.buildplatform == "Linux":
		OS.shell_open(mod_realPath)
	else:
		OS.shell_open(mod_realPath)

func grey_scale(toggle: bool) -> void:
	if toggle:
		mod_image_texture.material = greyscaleShader
	else:
		mod_image_texture.material = null

## Unload the Mod
func _set_loaded() -> void:
	_on_loadunload_pressed()

func _on_loadunload_pressed() -> void:
	if loaded:
		if get_parent() == disabledParent: return
		loaded = false
		loadunload.text = "Enable"
		loadunload.tooltip_text = "Enable the Mod"
		Engine.print_error_messages = false
		enabledParent.remove_child(self)
		disabledParent.add_child(self)
		Engine.print_error_messages = true
		if disabledParent.get_child_count() >= disabledIDX:
			disabledParent.move_child(self, disabledIDX)
		grey_scale(true)
	else:
		if get_parent() == enabledParent: return
		loaded = true
		loadunload.text = "Disable"
		loadunload.tooltip_text = "Disable the Mod"
		Engine.print_error_messages = false
		disabledParent.remove_child(self)
		enabledParent.add_child(self)
		Engine.print_error_messages = true
		grey_scale(false)

func _on_moveup_pressed() -> void:
	var parent = get_parent()
	if parent:
		if get_index() == 0:
			return
		if quicksort:
			parent.move_child(self, 0)
		else:
			parent.move_child(self, get_index() - 1)

func _on_movedown_pressed() -> void:
	var parent = get_parent()
	if parent:
		if quicksort:
			parent.move_child(self, parent.get_child_count() - 1)
		else:
			parent.move_child(self, get_index() + 1)

func _on_openinsteam_pressed() -> void:
	OS.shell_open("steam://openurl/https://steamcommunity.com/workshop/filedetails/?id={0}".format([mod_ID]))
