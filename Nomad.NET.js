// Nomad.NET.js
// Written by Bill Stewart
// Launcher script for Nomad.NET
//
// Dependencies:
// * nomad.exe must be in same directory as this script
// * nomad.exe.config must have the following setting in <settingsConfiguration> node:
//   <settingsProvider userLevel="PerUserRoaming" roamingUserConfigDir="%LOCALAPPDATA%\BMG\Nomad.NET\Config" />
//
// Nomad.NET root configuration data is stored at <LOCALAPPDATA>\BMG\Nomad.NET
// and has two directories under that:
//   Config - stores user.config file
//   Tools - stores tool shortcuts
// This launcher creates the directories if they don't exist and copies
// defaultUser.config to user.config and creates a default shortcut. If the
// directories already exist, just launch Nomad.NET.
//
// History:
//
// 2024/08/13:
// * Remove unused code.
//
// 2019/07/02:
// * Don't assign shortcut key to tool shortcut.
// * Launch Nomad.exe regardless of whether x86 or x64.
//
// 2018/09/13:
// * Create PowerShell shortcut if PowerShell installed; otherwise cmd.exe.
//
// 2016/03/31:
// * Initial version.

// Global constants
var DIALOG_TITLE    = "Nomad.NET";
var ssfLOCALAPPDATA = 0x1C;
var ssfSYSTEM       = 0x25;
var CONFIG_DIR_NAME = "BMG\\Nomad.NET";

// Global objects
var FSO = new ActiveXObject("Scripting.FileSystemObject");

// Returns n as a hex string.
function hex(n) {
  return n < 0 ? (n + Math.pow(2, 32)).toString(0x10) : n.toString(0x10);
}

// Creates a subdirectory tree starting at a specified path. Returns 0 for
// success, non-zero for failure.
function createTree(path) {
  var dirs = path.split("\\");
  var dir = "";
  for ( var i = 0; i < dirs.length; i++ ) {
    if ( dir != "")
      dir += "\\";
    dir += dirs[i];
    if ( ! FSO.FolderExists(dir) ) {
      try {
        FSO.CreateFolder(dir);
      }
      catch(err) {
        return err.number;
      }
    }
  }
  return 0;
}

function main() {
  var wshShell = new ActiveXObject("WScript.Shell");

  var scriptPath = WScript.ScriptFullName.substring(0, WScript.ScriptFullName.length - WScript.ScriptName.length);

  var nomadExec = FSO.BuildPath(scriptPath, "nomad.exe");

  // Fail if we can't find executable
  if ( ! FSO.FileExists(nomadExec) ) {
    wshShell.Popup("File not found - '" + nomadExec + "'", 0, DIALOG_TITLE, 16);
    return 2;  // ERROR_FILE_NOT_FOUND
  }

  // Get directory for user.config
  var shellApp = new ActiveXObject("Shell.Application");
  var rootConfigDir = FSO.BuildPath(shellApp.NameSpace(ssfLOCALAPPDATA).Self.Path, CONFIG_DIR_NAME);
  var configDir = FSO.BuildPath(rootConfigDir, "Config");

  // If doesn't exist, create, then copy defaultUser.config to user.config
  if ( ! FSO.FolderExists(configDir) ) {
    var result = createTree(configDir);
    if ( result == 0 ) {
      var sourceFile = FSO.BuildPath(scriptPath, "defaultUser.config");
      var targetFile = FSO.BuildPath(configDir, "user.config");
      try {
        FSO.CopyFile(sourceFile, targetFile);
      }
      catch(err) {
        wshShell.Popup("Error 0x" + hex(err.number) + " copying '" + sourceFile + "' to '" + targetFile + "'", 0, DIALOG_TITLE, 16);
      }
    }
    else {
      wshShell.Popup("Error 0x" + hex(result) + " creating directory - '" + configDir + "'", 0, DIALOG_TITLE, 16);
    }
  }

  // Get Tools directory
  var toolsDir = FSO.BuildPath(rootConfigDir, "Tools");

  // If doesn't exist, create, then create default shortcut
  if ( ! FSO.FolderExists(toolsDir) ) {
    var result = createTree(toolsDir);
    if ( result == 0 ) {
      var exePath = FSO.BuildPath(shellApp.NameSpace(ssfSYSTEM).Self.Path, "WindowsPowerShell\\v1.0\\powershell.exe");
      if ( FSO.FileExists(exePath) ) {
        var scTargetFile = FSO.BuildPath(toolsDir, "Windows PowerShell.lnk");
        var scArguments = "-NoExit -Command \"& Set-Location '%curdir%'\"";
      }
      else {
        exePath = FSO.BuildPath(shellApp.NameSpace(ssfSYSTEM).Self.Path, "cmd.exe");
        var scTargetFile = FSO.BuildPath(toolsDir, "Command Prompt.lnk");
        var scArguments = "/K CD /D \"%curdir%\"";
      }
      try {
        var wshShortcut = wshShell.CreateShortcut(scTargetFile);
        wshShortcut.TargetPath = exePath;
        wshShortcut.Arguments = scArguments;
        wshShortcut.Save();
      }
      catch(err) {
        wshShell.Popup("Error 0x" + hex(err.number) + " creating shortcut - '" + targetFile + "'", 0, DIALOG_TITLE, 16);
      }
    }
    else {
      wshShell.Popup("Error 0x" + hex(result) + " creating directory - '" + configDir + "'", 0, DIALOG_TITLE, 16);
    }
  }

  // Run executable, normal window, don't wait for termination
  wshShell.Run('"' + nomadExec + '"', 1, false);
}

WScript.Quit(main());
