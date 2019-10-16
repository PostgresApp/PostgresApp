create-dmg
==========

A shell script to build fancy DMGs.


Status and contribution policy
------------------------------

This project is maintained thanks to the contributors who send pull requests, and now (Sep 2018) with the help of [@aonez](https://github.com/aonez).

We will merge any pull request that adds something useful and does not break existing things, and will often grant commit access to the repository.

If you're an active user and want to be a maintainer, or just want to chat, please ping us at [gitter.im/create-dmg/Lobby](https://gitter.im/create-dmg/Lobby).


Installation
------------

- You can install this script using [Homebrew](https://brew.sh):

  ```sh
  brew install create-dmg
  ```

- You can download the [latest release](https://github.com/andreyvit/create-dmg/releases/latest)

- You can also clone the entire repository:

  ```sh
  git clone https://github.com/andreyvit/create-dmg.git
  ```

Usage
-----

```sh
create-dmg [options...] [output\_name.dmg] [source\_folder]
```

All contents of source\_folder will be copied into the disk image.

**Options:**

*   **--volname [name]:** set volume name (displayed in the Finder sidebar and window title)
*   **--volicon [icon.icns]:** set volume icon
*   **--background [pic.png]:** set folder background image (provide png, gif, jpg)
*   **--window-pos [x y]:** set position the folder window
*   **--window-size [width height]:** set size of the folder window
*   **--text-size [text size]:** set window text size (10-16)
*   **--icon-size [icon size]:** set window icons size (up to 128)
*   **--icon [file name] [x y]:** set position of the file's icon
*   **--hide-extension [file name]:** hide the extension of file
*   **--custom-icon [file name]/[custom icon]/[sample file] [x y]:** set position and custom icon
*   **--app-drop-link [x y]:** make a drop link to Applications, at location x, y
*   **--ql-drop-link [x y]:** make a drop link to /Library/QuickLook, at location x, y
*   **--eula [eula file]:** attach a license file to the dmg
*   **--rez [rez path]:** specify custom path to Rez tool used to include license file
*   **--no-internet-enable:** disable automatic mount&copy
*   **--format:** specify the final image format (default is UDZO)
*   **--add-file [target name] [path to source file] [x y]:** add additional file (option can be used multiple times)
*   **--add-folder [target name] [path to source folder] [x y]:** add additional folder (option can be used multiple times)
*   **--disk-image-size [x]:** set the disk image size manually to x MB
*   **--hdiutil-verbose:** execute hdiutil in verbose mode
*   **--hdiutil-quiet:** execute hdiutil in quiet mode
*   **--sandbox-safe:** execute hdiutil with sandbox compatibility and don not bless
*   **--version:** show tool version number
*   **-h, --help:** display the help


Example
-------

```sh
#!/bin/sh
test -f Application-Installer.dmg && rm Application-Installer.dmg
create-dmg \
--volname "Application Installer" \
--volicon "application\_icon.icns" \
--background "installer\_background.png" \
--window-pos 200 120 \
--window-size 800 400 \
--icon-size 100 \
--icon "Application.app" 200 190 \
--hide-extension "Application.app" \
--app-drop-link 600 185 \
"Application-Installer.dmg" \
"source_folder/"
```

Alternatives
------------

* [node-appdmg](https://github.com/LinusU/node-appdmg)
* [dmgbuild](https://pypi.python.org/pypi/dmgbuild)
* see the [StackOverflow question](http://stackoverflow.com/questions/96882/how-do-i-create-a-nice-looking-dmg-for-mac-os-x-using-command-line-tools)
