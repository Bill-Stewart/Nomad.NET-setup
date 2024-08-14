# Building Nomad.NET Setup

## Prerequisites

* [Inno Setup](https://www.jrsoftware.org/isinfo.php) version 6.3.1 or later

* Latest 32-bit [ProcessCheck.dll](https://github.com/Bill-Stewart/ProcessCheck/releases/)

* Latest 32-bit [UninsIS.dll](https://github.com/Bill-Stewart/UninsIS/releases/)

## Required Files

Put the files from the following table in a directory:

| File Name            | Description
| ---------            | -----------
| `defaultUser.config` | Default Nomad.NET per-user configuration file
| `Extract.ps1`        | Extracts the Nomad.NET zip file
| `license-en.rtf`     | License file displayed in Nomad.NET Setup
| `messages-en.isl`    | Nomad.NET Setup English language message file
| `Nomad.exe.config`   | Nomad.NET executable config file
| `Nomad.NET.ico`      | Nomad.NET icon
| `Nomad.NET.iss`      | Nomad.NET Setup Inno Setup script
| `Nomad.NET.js`       | Launcher script for Nomad.NET
| `ProcessCheck.dll`   | DLL used by Nomad.NET Setup
| `readme-en.rtf`      | Nomad.NET Setup information file
| `UninsIS.dll`        | DLL used by Nomad.NET Setup

In addition to the above, copy the most recent Nomad.NET zip file (e.g., `nomad-net_3_2_0_2890_final.zip`) to this directory.

## Expand the Archive

From a Windows PowerShell window, run the `Extract.ps1` script to expand the Nomad.NET zip file to its constitutent directories. Running this script extracts the Nomad.NET zip file to the following directories:

* `redist`

* `redist_x86`

* `redist_x64`

## Compile the Inno Setup Script

Use whatever method you prefer to compile the `Nomad.NET.iss` script using Inno Setup.
