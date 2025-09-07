extends Control

@onready var disabledmods: BoxContainer = $background/ModInfo/BoxContainer/Disabled/BoxContainer/Panel/ScrollContainer2/disabledmods
@onready var enabledmods: BoxContainer = $background/ModInfo/BoxContainer/Enabled/BoxContainer/Panel/ScrollContainer2/enabledmods
@onready var application_name: Label = $background/StatusBar/left/ApplicationName
@onready var background: ColorRect = $background

@onready var settings_menu: MenuButton = $background/BoxContainer/settingsMenu
@onready var modlist_menu: MenuButton = $background/BoxContainer/modlistMenu
@onready var missingModWindow: Control = $filedialog/missingmods

# Missing Mods instantiate into this
@onready var missingmodsbox: BoxContainer = $filedialog/missingmods/missingmodspanel/MarginContainer/BoxContainer2/ScrollContainer/missingmodsbox

var mod_info_scene: PackedScene = preload("uid://bvbhtvokj7f1g")
var firstTimeWindow: PackedScene = preload("uid://0oulcluvnstl")
var missing_mod_scene: PackedScene = preload("uid://tyf1wspsp4hj")

var disabledHideLocalMods: bool = false
var disabledHideWorkshopMods: bool = false
var enabledHideLocalMods: bool = false
var enabledHideWorkshopMods: bool = false

var disabledSearch: String = ""
var enabledSearch: String = ""

# This is the String we store the end Result Mods Element for the Options.xml
var modsString: String = ""
var modsCompatNumber: String = "35"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(OS.get_environment("USERNAME"))
	ffglobals.mainWindow = self
	application_name.text = "Door Kickers 2 Modlist Manager - Platform: {0} Version: {1}".format([ffglobals.buildplatform, ffglobals.buildversion])
	if !ffglobals.isFirstTime:
		startup()
	# Hookup the Menu Buttons
	modlist_menu.get_popup().connect("index_pressed",_modlist_buttons)
	settings_menu.get_popup().connect("index_pressed",_settings_buttons)



func _settings_buttons(idx: int) -> void:
	match idx:
		# Configuration
		0:
			print("Config")
		# AAAAAA
		1:
			$AudioStreamPlayer.play(0)
		# Should never happen
		_:
			pass

func _modlist_buttons(idx: int) -> void:
	match idx:
		# Save
		0:
			_modlist_save()
		# Load
		1:
			_modlist_load()
		# Should never happen
		_:
			pass

func _modlist_save() -> void:

	if enabledmods.get_child_count() == 0:
		OS.alert("You are trying to save a Modlist without Mods?\nAre you okay?","No Mods Enabled")
		return

	# Open Dialog
	var dialog = FileDialog.new()
	dialog.set_file_mode(FileDialog.FILE_MODE_SAVE_FILE)
	dialog.set_access(FileDialog.ACCESS_FILESYSTEM)
	dialog.set_use_native_dialog(true)
	dialog.connect("file_selected", _save_dialog)
	$filedialog.add_child(dialog)
	dialog.popup_centered_ratio()
	dialog.title = "Save Modlist to File"

func _save_dialog(path: String) -> void:
	var fileName: String = ""
	var folderPath: String = ""
	var sep: String = "/"
	match ffglobals.buildplatform:
		"Windows":
			var p = path.split("/", false)
			fileName = p[-1]
			p.remove_at(p.size() - 1)
			folderPath = "/".join(p)
			sep = "\\"
		"Linux":
			var p = path.split("/", false)
			fileName = p[-1]
			p.remove_at(p.size() - 1)
			folderPath = "/".join(p)
			sep = "/"
	fileName = fileName.get_basename()

	# Build Modlist File
	var modListFileText = "<DK2Mods>\n"
	for m in enabledmods.get_children():
		modListFileText += "\t<Mod name=\"{0}\" id=\"{1}\"/>\n".format([m.mod_name, m.mod_ID])
	modListFileText += "</DK2Mods>"

	var file
	if ffglobals.buildplatform == "Linux":
		file = FileAccess.open("{1}{0}{1}{2}.xml".format([folderPath,sep,fileName]),FileAccess.WRITE)
	if ffglobals.buildplatform == "Windows":
		file = FileAccess.open("{0}/{1}.xml".format([folderPath,fileName]), FileAccess.WRITE)

	file.store_string(modListFileText)
	file.close()

func _modlist_load() -> void:
	# Open Dialog
	var dialog = FileDialog.new()
	dialog.set_file_mode(FileDialog.FILE_MODE_OPEN_FILE)
	dialog.set_access(FileDialog.ACCESS_FILESYSTEM)
	dialog.set_use_native_dialog(true)
	dialog.connect("file_selected", _load_dialog)
	$filedialog.add_child(dialog)
	dialog.popup_centered_ratio()
	dialog.title = "Load Modlist from File"

func _load_dialog(path: String) -> void:
	if !FileAccess.file_exists(path):
		OS.alert("The File you selected doesn't seem to exist", "File Doesn't Exist")

	var file = FileAccess.open(path,FileAccess.READ)
	var text = file.get_as_text().split("\n")
	file.close()

	if !text[0].containsn("<DK2Mods>"):
		OS.alert("This isn't a Valid Modlist File, maybe it's corrupted or you have chosen the Wrong file", "Not Modlist File")
		return

	for i in enabledmods.get_children():
		i._set_loaded()
	filter_mods(false)

	# Filter out the Outer Element
	for t in text:
		if t.containsn("<DK2Mods>"):
			text.remove_at(text.find("<DK2Mods>"))
		if t.containsn("</DK2Mods>"):
			text.remove_at(text.find("</DK2Mods>"))

	# Loaded Mods
	var loadedList: Array = []

	for l in text:
		l = l.strip_edges()
		var s = l.split("\"", false)
		# If it's empty we just skip it
		if s == PackedStringArray():
			continue
		# 1 is Mod name, 3 is Mod ID
		loadedList.append([s[1],s[3]])
	for e in loadedList:
		print("Searching for Mod: " + e[0])

		var curMod: String = e[0]
		var curModID: String = e[1]

		for m in disabledmods.get_children():
			if m.mod_name == e[0] && m.mod_ID == e[1]:
				print("Found Mod: " + e[0])
				m._set_loaded()
				print("Loaded Mod: " + e[0])
				curMod = ""
				curModID = ""
		if curMod != "" && curModID != "":	_addMissingMod(e[0], e[1])

	if missingmodsbox.get_child_count() >= 1:
		missingModWindow.show()

func _on_close_missingmods_pressed() -> void:
	missingModWindow.hide()
	for c in missingmodsbox.get_children():
		c.queue_free()

func _addMissingMod(m_name: String, id: String) -> void:
	var m = missing_mod_scene.instantiate()
	missingmodsbox.add_child(m)
	m.construct(m_name, id)

func startup() -> void:
	# Parse the Saved Configuration
	var settingsSaveContent: Dictionary = {}

	if FileAccess.file_exists(ffglobals.settingsFile):
		var file = FileAccess.open(ffglobals.settingsFile, FileAccess.READ)
		settingsSaveContent = JSON.parse_string(file.get_as_text())
		file.close()
		# Insane Double Check to see if it works
		if settingsSaveContent.get_or_add("GameInstallPath") != null:
			ffglobals.installDirectory = settingsSaveContent["GameInstallPath"]
		else:
			OS.alert("It appears the Settings File is corrupted or otherwise incorrect\n\nThe Program will run through the Configuration again.","Corrupted Settings File")
			DirAccess.remove_absolute(ffglobals.settingsFile)
			file.close()
			_make_first_time_window()
			return

		if settingsSaveContent.get_or_add("WorkshopDirectory") != null:
			ffglobals.workshopDirectory = settingsSaveContent["WorkshopDirectory"]
		else:
			OS.alert("It appears the Settings File is corrupted or otherwise incorrect\n\nThe Program will run through the Configuration again.","Corrupted Settings File")
			DirAccess.remove_absolute(ffglobals.settingsFile)
			file.close()
			_make_first_time_window()
			return

		if settingsSaveContent.get_or_add("AppdataDirectory") != null:
			ffglobals.appdataDirectory = settingsSaveContent["AppdataDirectory"]
		else:
			OS.alert("It appears the Settings File is corrupted or otherwise incorrect\n\nThe Program will run through the Configuration again.","Corrupted Settings File")
			DirAccess.remove_absolute(ffglobals.settingsFile)
			file.close()
			_make_first_time_window()
			return

	locate_mods()

func _make_first_time_window() -> void:
	ffglobals.firstTimeWindow.visible = true

func locate_mods() -> void:
	# Build the Folder to the Real Mods Folder
	var realWorkshopPath = "{0}/content/1239080".format([ffglobals.workshopDirectory])
	var realpath = []
	var prefix = ""
	if ffglobals.buildplatform == "Linux":
		OS.execute("realpath", [realWorkshopPath], realpath)
		prefix = "Z:"

	for dir in DirAccess.get_directories_at(realWorkshopPath):

		# Get Entire Folder Path
		var dirpath = "{0}/{1}".format([realWorkshopPath,dir])

		# Return early if we can't find the XML, likely a Map and not a Mod
		if !FileAccess.file_exists(dirpath + "/mod.xml"):
			continue

		# Get The Mod Image
		var tex
		var image
		if FileAccess.file_exists("{0}/mod_image.jpg".format([dirpath])):
			Engine.print_error_messages = false
			image = Image.load_from_file("{0}/mod_image.jpg".format([dirpath]))
			tex = ImageTexture.create_from_image(image)
			Engine.print_error_messages = true

		# Parse the XML
		var parser = XMLParser.new()
		parser.open("{0}/mod.xml".format([dirpath])) #TODO
		while parser.read() != ERR_FILE_EOF:
			if parser.get_node_type() == XMLParser.NODE_ELEMENT:
				var _node_name = parser.get_node_name()
				var _attributes_dict = {}
		var mod = mod_info_scene.instantiate()
		disabledmods.add_child(mod)
		mod.disabledParent = disabledmods
		mod.enabledParent = enabledmods
		mod.mod_realPath = dirpath ## Only a Linux thing

		# Linux Fuckery
		if ffglobals.buildplatform == "Linux":
			dirpath = "{0}{1}/{2}".format([prefix,realpath[0],dir])

		mod.construct(tex, parser.get_named_attribute_value("title"), parser.get_named_attribute_value("author"), false, dirpath, dir)

	# Local Mods
	var localModsPath = "{0}/mods".format([ffglobals.installDirectory])
	var localUploadMods = "{0}/mods_upload".format([ffglobals.installDirectory])
	var appdataModsPath = "{0}/mods".format([ffglobals.appdataDirectory])
	var appdataUploadMods = "{0}/mods_upload".format([ffglobals.appdataDirectory])
	await _load_local_mods(localModsPath, "Z:")
	await _load_local_mods(localUploadMods, "Z:")
	await _load_local_mods(appdataModsPath, "C:", true)
	await _load_local_mods(appdataUploadMods, "C:", true)

	sort_mods()

## Load Local Mods from the Specified Path
func _load_local_mods(path: String, prefix: String, linuxAppdata: bool = false):
	if !ffglobals.buildplatform == "Linux":
		prefix = ""
		linuxAppdata = false

	for dir in DirAccess.get_directories_at(path):
		if dir == "os_steam_deck": continue

		# Get Entire Folder Path
		var dirpath = "{0}/{1}".format([path,dir])
		# Return early if we can't find the XML, likely a Map and not a Mod
		if !FileAccess.file_exists(dirpath + "/mod.xml"):
			continue

		# Get The Mod Image
		var tex
		if FileAccess.file_exists("{0}/mod_image.jpg".format([dirpath])):
			var image = Image.load_from_file("{0}/mod_image.jpg".format([dirpath]))
			tex = ImageTexture.create_from_image(image)

		# Parse the XML
		var parser = XMLParser.new()
		parser.open("{0}/mod.xml".format([dirpath]))
		while parser.read() != ERR_FILE_EOF:
			if parser.get_node_type() == XMLParser.NODE_ELEMENT:
				var _node_name = parser.get_node_name()
				var _attributes_dict = {}
		var mod = mod_info_scene.instantiate()
		disabledmods.add_child.call_deferred(mod)
		mod.disabledParent = disabledmods
		mod.enabledParent = enabledmods

		# Special Handling for Linux Appdata
		mod.mod_realPath = dirpath
		if linuxAppdata:
			prefix = ""
			dirpath = "C:/users/steamuser/AppData/Local/KillHouseGames/DoorKickers2/{0}/{1}".format([dirpath.split("/")[-2],dir])
		await mod.ready
		await mod.construct(tex, parser.get_named_attribute_value_safe("title"), parser.get_named_attribute_value_safe("author"), true, "{0}{1}".format([prefix,dirpath]), "0")

func sort_mods() -> void:
	checkLoadedMods()

func checkLoadedMods() -> void:
	var file = FileAccess.open("{0}/options.xml".format([ffglobals.appdataDirectory]),FileAccess.READ)
	if !file:
		OS.alert("Woops It seems your Options.xml in your Appdata failed to Load\nDouble check the Permissions on the File/Folder","Unable to Read Options.xml")
		get_tree().quit()

	# Parse the XML

	var split = file.get_as_text().split("\n")
	file.close()
	var modsline = ""
	for s in split:
		if s.containsn("<mods compat="): modsline = s

	# If the Options.xml has no Mods loaded this will remain empty
	if !modsline == "":
		var modslinearr: PackedStringArray = modsline.split("\" ", false)
		var modRealPath: String = ""
		# Mod Compat Version Thing
		modsCompatNumber = modslinearr[0].strip_edges()
		modsCompatNumber = modsCompatNumber.trim_prefix("<Mods compat=\"")
		modsCompatNumber = modsCompatNumber.trim_suffix("\"")

		for i in range(1, modslinearr.size()):
			var modPath: String = modslinearr[i]
			modPath = modPath.split("\"")[1]
			modPath = modPath.replace("\\", "/")
			modRealPath = modPath
			modPath = modPath.split("/")[-1]

			# Find the Mod

			for m in disabledmods.get_children():
				var path = m.mod_path
				var id = m.mod_ID

				# Grab Final Folder
				path = path.split("/")[-1]

				# Local Mods
				if m.isLocalMod:
					#print("Checking if {0} Contains {1}".format([modRealPath, path]))
					if modRealPath.containsn(path):
						#print("It does")
						m._set_loaded()

				if !m.isLocalMod:
					if modPath == id:
						m._set_loaded()

	filter_mods(false)
	filter_mods(true)
		#disabledmods
		#enabledmods

# Close Program
func _on_exit_pressed() -> void:
	get_tree().quit()

# Open in Steam
func _on_launch_pressed() -> void:
	_on_apply_pressed()
	OS.shell_open("steam://rungameid/1239080")

func _on_nomodlaunch_pressed() -> void:
	_on_apply_pressed(false)
	OS.shell_open("steam://rungameid/1239080")

# Unload all Mods
func _on_unloadall_pressed() -> void:
	for i in enabledmods.get_children():
		i._set_loaded()
	filter_mods(false)

func _on_openappdata_pressed() -> void:
	OS.shell_open(ffglobals.appdataDirectory)

# Refresh All Mods
func _on_reloadmods_pressed() -> void:
	for i in enabledmods.get_children():
		i.queue_free()
	for i in disabledmods.get_children():
		i.queue_free()
	startup()

# Apply the Enabled Modlist
func _on_apply_pressed(modded: bool = true) -> void:
	var hasMods: bool = true
	var count := 0

	# We want to not load any mods
	if enabledmods.get_child_count() == 0:
		hasMods = false
	if !modded:
		hasMods = false

	# Lets get the action Options XML and try to replace the Line for the Mods only
	var file = FileAccess.open("{0}/options.xml".format([ffglobals.appdataDirectory]),FileAccess.READ)
	if !file:
		OS.alert("Woops It seems your Options.xml in your Appdata failed to Load\nDouble check the Permissions on the File/Folder","Unable to Read Options.xml")
		get_tree().quit()

	# Parse the XML
	modsString = "<Mods compat=\"{0}\"".format([modsCompatNumber])
	for m in enabledmods.get_children():
		var localpath = m.mod_path
		#print(localpath)
		if m.mod_path.replace("\\","/").containsn("common/DoorKickers2/mods"):
			var temp = m.mod_path.split("/")
			localpath = "mods/{0}".format([temp[-1]])
		elif m.mod_path.replace("\\","/").containsn("common/DoorKickers2/mods_upload"):
			var temp = m.mod_path.split("/")
			localpath = "mods_upload/{0}".format([temp[-1]])
		if ffglobals.buildplatform == "Linux":
			modsString = "{0} path{1}=\"{2}\"".format([modsString, str(count), localpath.replace("\\","/")])
		else:
			if !m.isLocalMod:
				localpath = localpath.replace("/","\\")
			modsString = "{0} path{1}=\"{2}\"".format([modsString, str(count), localpath])
		print(localpath)
		count += 1

	modsString = "{0}/>".format([modsString])

	var optionsXML: String = ""
	var appliedMods: bool = false
	var split = file.get_as_text().split("\n")
	file.close()
	for s in split:
		if s.containsn("<mods compat=") && !appliedMods && hasMods:
					# Mod Compat Version Thing
			optionsXML += "    {0}\n".format([modsString])
			appliedMods = true
		# If we get to Devmode without mods being applied we need to inject it here
		elif s.containsn("<devmode") && !appliedMods && hasMods:
			optionsXML += "    {0}\n".format([modsString])
			optionsXML += "{0}\n".format([s])
			appliedMods = true
		elif s.containsn("<mods compat=") && !hasMods:
			pass
		else:
			optionsXML += "{0}\n".format([s])

	# Close the FIle first
	file.close()

	# Now we reopen it as a Write
	file = FileAccess.open("{0}/options.xml".format([ffglobals.appdataDirectory]),FileAccess.WRITE)
	file.store_string(optionsXML)
	file.close()

## Funky ass Filter
func filter_mods(side: bool) -> void:
	# Enabled Side
	if side:
		for m in enabledmods.get_children():
			# Name Filter
			if !enabledSearch == "":
				# Local Mod
				if m.name.containsn(enabledSearch) && m.isLocalMod && !enabledHideLocalMods:
					m.visible = true
				elif !m.name.containsn(enabledSearch):
					m.visible = false

				if m.name.containsn(enabledSearch) && m.isLocalMod && enabledHideLocalMods:
					m.visible = false

				# Workshop Mod
				if m.name.containsn(enabledSearch) && !m.isLocalMod && !enabledHideWorkshopMods:
					m.visible = true
				elif !m.name.containsn(enabledSearch):
					m.visible = false

				if m.name.containsn(enabledSearch) && !m.isLocalMod && enabledHideWorkshopMods:
					m.visible = false

			else:
				# We only Worry about Type Filtering
				if m.isLocalMod && enabledHideLocalMods:
					m.hide()
				elif m.isLocalMod && !enabledHideLocalMods:
					m.show()

				if !m.isLocalMod && enabledHideWorkshopMods:
					m.visible = false
				elif !m.isLocalMod && !enabledHideWorkshopMods:
					m.visible = true
	# Disabled Side
	else:
		# Filter the Names

		for m in disabledmods.get_children():
			# Name Filter
			if !disabledSearch == "":
				# Local Mod
				if m.name.containsn(disabledSearch) && m.isLocalMod && !disabledHideLocalMods:
					m.visible = true
				elif !m.name.containsn(disabledSearch):
					m.visible = false

				if m.name.containsn(disabledSearch) && m.isLocalMod && disabledHideLocalMods:
					m.visible = false

				# Workshop Mod
				if m.name.containsn(disabledSearch) && !m.isLocalMod && !disabledHideWorkshopMods:
					m.visible = true
				elif !m.name.containsn(disabledSearch):
					m.visible = false

				if m.name.containsn(disabledSearch) && !m.isLocalMod && disabledHideWorkshopMods:
					m.visible = false

			else:
				# We only Worry about Type Filtering
				if m.isLocalMod && disabledHideLocalMods:
					m.visible = false
				elif m.isLocalMod && !disabledHideLocalMods:
					m.visible = true

				if !m.isLocalMod && disabledHideWorkshopMods:
					m.visible = false
				elif !m.isLocalMod && !disabledHideWorkshopMods:
					m.visible = true

#region Visibility Events
func _on_disabled_local_toggled(toggled_on: bool) -> void:
	disabledHideLocalMods = toggled_on
	filter_mods(false)

func _on_disabled_workshop_toggled(toggled_on: bool) -> void:
	disabledHideWorkshopMods = toggled_on
	filter_mods(false)

func _on_enabled_local_toggled(toggled_on: bool) -> void:
	enabledHideLocalMods = toggled_on
	filter_mods(true)

func _on_enabled_workshop_toggled(toggled_on: bool) -> void:
	enabledHideWorkshopMods = toggled_on
	filter_mods(true)
#endregion


#region Search Events
func _on_enabled_search_text_submitted(new_text: String) -> void:
	enabledSearch = new_text
	filter_mods(true)
func _on_disabled_search_text_submitted(new_text: String) -> void:
	disabledSearch = new_text
	filter_mods(false)

func _on_enabled_search_text_changed(new_text: String) -> void:
	enabledSearch = new_text
	filter_mods(true)
func _on_disabled_search_text_changed(new_text: String) -> void:
	disabledSearch = new_text
	filter_mods(false)
#endregion
