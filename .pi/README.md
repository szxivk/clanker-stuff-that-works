# Pi setup

This directory contains Pi-related configuration and extensions for this collection.

## Local extensions

Copy a local extension into your user-level Pi extensions directory, then start Pi:

```sh
mkdir -p ~/.pi/agent/extensions
cp -R .pi/agent/extensions/<extension> ~/.pi/agent/extensions/
```

For a single-file extension, copy the `.ts` file into `~/.pi/agent/extensions/`. Follow any extension-specific setup instructions in its directory.

## npm packages

The `packages` list in `agent/settings.json` includes these npm packages. They are not folders in `agent/extensions/`. Pi loads packages from your settings. You can install or read about each package at its Pi package page:

- [pi-mcp-adapter](https://pi.dev/packages/pi-mcp-adapter)
- [pi-toggle-skills](https://pi.dev/packages/pi-toggle-skills?name=skill+toggle)
- [pi-welcome-screen](https://pi.dev/packages/@pi-kaush/pi-welcome-screen?name=pi-welcome-screen)
- [btw](https://pi.dev/packages/@narumitw/pi-btw?name=btw)
- [pix-optimizer](https://pi.dev/packages/@xynogen/pix-optimizer?name=pix+optimizer)

The checked-in `agent/settings.json` is part of this collection. Add packages to your own Pi settings or use the package pages to install them. Do not replace your personal settings without checking the file first.

Load extensions and packages only from sources you trust. They run with Pi's operating-system permissions.
