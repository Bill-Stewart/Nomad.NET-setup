<!-- omit in toc -->
# Nomad.NET Setup

Nomad.NET Setup is an Inno Setup installer for the free Windows Nomad.NET file manager.

<!-- omit in toc -->
# Table of Contents
- [Download](#download)
- [Nomad.NET Setup System Requirements](#nomadnet-setup-system-requirements)
- [Nomad.NET Setup Command Line Parameters](#nomadnet-setup-command-line-parameters)
- [Installing without User Interaction](#installing-without-user-interaction)
- [Creating a Desktop Shortcut](#creating-a-desktop-shortcut)
- [Removing the Desktop Shortcut](#removing-the-desktop-shortcut)

## Download

https://github.com/Bill-Stewart/Nomad.NET-setup/releases/

## Nomad.NET Setup System Requirements

Nomad.NET Setup requires Windows 7 or Windows Server 2008 R2 with SP1 or newer.

## Nomad.NET Setup Command Line Parameters

| Parameter             | Description
| ---------             | -----------
| `/allusers`           | Runs Nomad.NET Setup for all users of the computer (requires administrator privileges).
| `/currentuser`        | Runs Nomad.NET Setup for the current user only (does not require administrator privileges).
| `/dir="`_location_`"` | Specifies the installation directory. The default location is _d_`:\Program Files\Nomad.NET` (where _d_`:` is the Windows system partition, typically `C:`).
| `/tasks=desktopicon`  | Creates a desktop shortcut. (For more information, see [**Creating a Desktop Shortcut**](#creating-a-desktop-shortcut), below.)
| `/tasks=!desktopicon` | Removes the desktop shortcut when reinstalling or upgrading. (For more information see [**Removing the Desktop Shortcut**](#removing-the-desktop-shortcut), below.)
| `/silent`             | Runs Nomad.NET Setup without user interaction. (For more information, see [**Installing without User Interaction**](#installing-without-user-interaction), below.)
| `/log="`_filename_`"` | Logs Nomad.NET Setup activity to the specified file. The default is not to create a log file.

## Installing without User Interaction

The following notes apply to running Nomad.NET Setup without user interaction:

* To install silently for all users, specify both `/silent` and `/allusers` on the Nomad.NET Setup command line. If you start Nomad.NET Setup without administrator privileges, Windows will prompt for administrator privileges using a User Account Control (UAC) prompt. You cannot bypass the UAC prompt; to prevent the UAC prompt from pausing or cancelling the installation process, start Nomad.NET Setup from a process that already has administrative privileges.

* To install silently for the current user only, specify both `/silent` and `/currentuser` on the Nomad.NET Setup command line. Installing for the current user does not require administrator privileges and does not display a UAC prompt.

## Creating a Desktop Shortcut

If you want Nomad.NET Setup to create a desktop shortcut, do one of the following:

* Select the **Create desktop icon** on the **Additional Tasks** page of the Nomad.NET Setup wizard, or

* Specify the `/tasks=desktopicon` parameter on Nomad.NET Setup's command line.

The `/tasks=desktopicon` parameter is identical to selecting the **Create desktop icon** check box on the **Additional Tasks** page of the Nomad.NET Setup wizard (they both enable the setting). Nomad.NET Setup will remember the setting for subsequent reinstalls or upgrades.

## Removing the Desktop Shortcut

If you want Nomad.NET Setup to remove the desktop shortcut when reinstalling or upgrading, do one of the following:

* Deslect the **Create desktop icon** on the **Additional Tasks** page of the Nomad.NET Setup wizard, or

* Specify the `/tasks=!desktopicon` parameter on Nomad.NET Setup's command line.

The `/tasks=!desktopicon` parameter is identical to deslecting the **Create desktop icon** checkbox on the **Additional Tasks** page of the Nomad.NET Setup wizard (they both disable the setting). Nomad.NET Setup will remember the setting for subsequent reinstalls or upgrades.
