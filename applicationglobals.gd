extends Node


const author := "Fluffy"
var buildversion := "0.0.1"
var latestversion := "0.0.1"
var buildplatform := "platform"

var installDirectory := ""
var appdataDirectory := ""
var workshopDirectory := ""
var localModDirectory := ""

var settingsFile := ""

# Application Root
@onready var root: Node = $"."

# First Time Window
var isFirstTime: bool = true
var firstTimeWindow: Control

# Ordering Mods Stuff
var isDragging = false
var mainWindow: Control

func _ready() -> void:
	# We need to Determine which Platform the User is using
	match OS.get_name():
		"Windows":
			buildplatform = "Windows"
			_process_paths(0)

		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			buildplatform = "Linux"
			_process_paths(1)

		"macOS":
			buildplatform = "macOS"
			OS.alert("Unfortunately I don't Support macOS Currently, Sorry!","Unsupported Platform")
			get_tree().quit()

		_:
			OS.alert("Contact Fluffy and Listen to their Instructions\n\nThe Application can't determine what System you are running this on thus the rest of it's Functions will not work\n\nReported System Platform: \"{0}\"".format([OS.get_name()]),"Unknown System Platform")
			get_tree().quit()

	# We need to check if this is the first time the Program has been run
	settingsFile = OS.get_executable_path().get_base_dir().path_join("DK2ModlistManagerSettings.json")

	if FileAccess.file_exists(settingsFile):
		isFirstTime = false

func _process_paths(type: int) -> void:
	match type:
		# Windows
		0:
			var drive = OS.get_environment("windir")
			drive = drive.erase(3, drive.length() - 3)
			var user = OS.get_environment("USERNAME")

			var path = drive + "Users\\" + user + "\\AppData\\Local/"
			appdataDirectory = path + "KillHouseGames/DoorKickers2"
		# Linux
		1:
			appdataDirectory = "../../compatdata/1239080/pfx/drive_c/users/steamuser/AppData/Local/KillHouseGames/DoorKickers2"
		# Unknown
		_:
			OS.alert("Not sure how you even got to this Error","Jesus Christ")


func update_appdata_directory() -> void:
	pass
func update_install_directory() -> void:
	pass
func update_workshop_directory() -> void:
	pass
