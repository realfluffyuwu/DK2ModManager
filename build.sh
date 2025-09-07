#!/usr/bin/env bash

/home/jordon/Programs/Godot4.5RC/nomono/Godot_v4.5-rc1_linux.x86_64 --headless --path ~/DeveloperWork/Doorkickers2/ProjectDK2ModManager/ --export-release "Linux" ~/DeveloperWork/Doorkickers2/DK2ModManager/Linux/DK2ModManager.x86_64
/home/jordon/Programs/Godot4.5RC/mono/Godot_v4.5-rc1_mono_linux.x86_64 --headless --path ~/DeveloperWork/Doorkickers2/ProjectDK2ModManager/ --export-release "Windows Desktop" ~/DeveloperWork/Doorkickers2/DK2ModManager/Windows/DK2ModlistManager.exe

cd ~/DeveloperWork/Doorkickers2/DK2ModManager/
./package.sh

