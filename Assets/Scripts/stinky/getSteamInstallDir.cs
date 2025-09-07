using Godot;
using Microsoft.Win32;
using System;

public partial class getSteamInstallDir : Node
{
	public string GetSteamDir()
	{
		string keyPath = @"SOFTWARE\WOW6432Node\Valve\Steam";
		try
		{
			using RegistryKey key = Registry.LocalMachine.OpenSubKey(keyPath);
			return key.GetValue("InstallPath") as string;
		}
		catch (System.Exception)
		{
			GD.Print("Error");
			throw;
		}
	}
}
