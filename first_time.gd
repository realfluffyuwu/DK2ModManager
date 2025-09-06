extends Control

var recalled = false

@onready var steaminstallfinder: Button = $ColorRect/Panel2/BoxContainer/steaminstallfinder

func _ready() -> void:
	ffglobals.firstTimeWindow = self
	if !ffglobals.isFirstTime:
		visible = false
	if ffglobals.buildplatform == "Linux":
		steaminstallfinder.hide()

func completeFirstTime() -> void:
	visible = false

	# Parse the Stuff to Settings to Save the Configuration
	var settingsData: Dictionary = {}
	settingsData.set("GameInstallPath", ffglobals.installDirectory)
	settingsData.set("WorkshopDirectory", ffglobals.workshopDirectory)
	settingsData.set("AppdataDirectory", ffglobals.appdataDirectory)
	var parsed = JSON.stringify(settingsData, "\t")
	var settingsFile = FileAccess.open(ffglobals.settingsFile,FileAccess.WRITE)
	settingsFile.store_string(parsed)
	settingsFile.close()

	$"../Timer".start()
	await $"../Timer".timeout

	ffglobals.mainWindow.startup()

func _on_steam_pressed() -> void:
	OS.shell_open("steam://gameproperties/1239080")

func _on_locate_pressed() -> void:
	var dialog = FileDialog.new()
	dialog.set_file_mode(FileDialog.FILE_MODE_OPEN_DIR)
	dialog.set_access(FileDialog.ACCESS_FILESYSTEM)
	dialog.set_use_native_dialog(true) ## This is what you want
	dialog.connect("dir_selected", _on_dir_selected)
	add_child(dialog)
	dialog.popup_centered_ratio()

func _on_dir_selected(path: String):
	var selected_path = "{0}/{1}".format([path,"DoorKickers2.exe"])
	var realpath = []
	match ffglobals.buildplatform:
		# Can't Resolve Links yet in Windows
		"Windows":
			if FileAccess.file_exists(selected_path):
				ffglobals.installDirectory = selected_path.get_base_dir()
				if DirAccess.dir_exists_absolute(ffglobals.appdataDirectory):
					pass
				else:
					OS.alert("Are you sure this is the Door Kickers 2 Installation Directory?\n\nYour Appdata Folder can't be found\n\nIf this is incorrect Contact Fluffy and Listen to their Instructions","Appdata Not Found")
					return

				# Just incase I completely break someones settings, I will backup it up first
				var file = FileAccess.open("{0}/options.xml".format([ffglobals.appdataDirectory]),FileAccess.READ)
				var backup = FileAccess.open("{0}/options.xml.backup".format([ffglobals.appdataDirectory]),FileAccess.WRITE)
				backup.store_string(file.get_as_text())

				_findWorkshopFolder()
				completeFirstTime()
			else:
				OS.alert("Are you sure this is the Door Kickers 2 Installation Directory?\n\nIt needs to Include the Door Kickers 2 Executable","Door Kickers 2 Not Found")

		# We can resolve Links in Linux
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			OS.execute("realpath", [selected_path], realpath)
			if FileAccess.file_exists(selected_path):
				ffglobals.installDirectory = realpath[0].get_base_dir()
				ffglobals.appdataDirectory = "{0}/{1}".format([ffglobals.installDirectory,ffglobals.appdataDirectory])
				if !DirAccess.dir_exists_absolute(ffglobals.appdataDirectory):
					OS.alert("Are you sure this is the Door Kickers 2 Installation Directory?\n\nYour Appdata Folder can't be found\n\nIf this is incorrect Contact Fluffy and Listen to their Instructions","Appdata Not Found")

				# Just incase I completely break someones settings, I will backup it up first
				var file = FileAccess.open("{0}/options.xml".format([ffglobals.appdataDirectory]),FileAccess.READ)
				var backup = FileAccess.open("{0}/options.xml.backup".format([ffglobals.appdataDirectory]),FileAccess.WRITE)
				backup.store_string(file.get_as_text())

				# Continue on
				_findWorkshopFolder()
				completeFirstTime()
			else:
				OS.alert("Are you sure this is the Door Kickers 2 Installation Directory?\n\nIt needs to Include the Door Kickers 2 Executable","Door Kickers 2 Not Found")
				return

func _findWorkshopFolder() -> void:
	# We now need to check it's a Valid installation of Door Kickers 2, Also by pure Technicality Anti Piracy
	var workshopPath = "{0}/../../workshop".format([ffglobals.installDirectory])

	if ffglobals.buildplatform == "Windows":
		print("Before: " + workshopPath)
		var s = workshopPath.find("steamapps/")
		workshopPath = workshopPath.erase(s + 10, workshopPath.length())
		workshopPath += "workshop"
		print("After: " + workshopPath)

	if DirAccess.dir_exists_absolute(workshopPath):
		# Workshop Folder exists
		ffglobals.workshopDirectory = workshopPath
	else:
		OS.alert("Are you sure this is the Door Kickers 2 Installation Directory?\n\nThe Workshop Folder can't be found either you have Selected the Wrong folder or Your game is Pirated\n\nIf this is incorrect Contact Fluffy and Listen to their Instructions","Workshop Not Found")
		return

func _on_steaminstallfinder_pressed() -> void:
	_find_game_path()

func _find_game_path() -> void:
	#var fileaccess: Dictionary = OS.execute_with_pipe("cmd.exe" ,["/c", ffglobals.steamInstallHelper], true)
	#var output: FileAccess = fileaccess["stdio"]
	#var steampath = output.get_line()
	var steampath: String = ""
	if ffglobals.buildplatform == "Windows":
		var getInstallDir = load("uid://ck05bvw4s58ui")
		var cs = getInstallDir.new()
		steampath = cs.GetSteamDir()
	# I'm done with the FileAccess so I close it here
	#output.close()
	#fileaccess["stderr"].close()
	
	steampath = "\\".join([steampath,"steamapps"])
	if FileAccess.file_exists(steampath.path_join("libraryfolders.vdf")):
		# Open the File
		var vdf: FileAccess = FileAccess.open(steampath.path_join("libraryfolders.vdf"),FileAccess.READ)
		# Dump the File
		var vdfoutput = vdf.get_as_text()
		# Close the File since we have the Output
		vdf.close()
		var path = _returnDK2Path(vdfoutput)
		if path == "":
			print("Game Path wasn't Found")
		path = path.split("\"", false)
		path = path[path.size() - 1].replace("\\\\", "\\")
		ffglobals.installDirectory = path.path_join("steamapps/common/DoorKickers2").replace("/","\\")
		ffglobals.workshopDirectory = path.path_join("steamapps/workshop").replace("/","\\")
		
		completeFirstTime()
	else:
		OS.alert("Unable to Locate your Install Directory Automatically, Please locate it manually", "Unable to Find DoorKickers 2 Install Directory")

func _returnDK2Path(vdfoutput: String) -> String:
	var s = vdfoutput.split("\n")
	var path: String = ""
	for t in s:
		if t.containsn("path"):
			path = t
		if t.containsn("1239080"):
			return path
	return ""
