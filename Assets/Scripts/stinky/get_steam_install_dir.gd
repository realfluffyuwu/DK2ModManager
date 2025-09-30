extends Node

func get_steam_dir() -> String:
	if OS.has_feature("windows"):
		var output = []
		var exit_code = OS.execute("reg", ["query", "HKLM\\SOFTWARE\\WOW6432Node\\Valve\\Steam", "/v", "InstallPath"], output, true, false)

		if exit_code == 0 and output.size() > 0:
			var result = output[0]
			# Parse the registry output to extract the InstallPath value
			var lines = result.split("\n")
			for line in lines:
				if "InstallPath" in line and "REG_SZ" in line:
					var parts = line.split("REG_SZ")
					if parts.size() > 1:
						return parts[1].strip_edges()

		push_error("Failed to read Steam install directory from registry")
		return ""
	else:
		push_error("Steam directory lookup is only supported on Windows")
		return ""
