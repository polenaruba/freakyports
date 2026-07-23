# Pharos Ports Template Repository

This repository is a template intended to be forked and used as a base for your own ports or wine bottles repository. The structure is:

- `.github/workflows`
  - In here you will find a sample screenshot collector. It will collect all screenshot image files it finds and bundle them into one `images.zip` release, which Pharos will pull and unzip for local screenshot rendering. (Ports repositories also get an `images.zip` on `ports-latest` from the PortMaster catalog step, which Pharos prefers — the standalone collector mainly matters for bottles repositories.)
  - You will also find a sample YAML to generate port or bottle releases. This will run every 12 hours or when there's a change in `ports/*` or `bottles/*`. You can modify this easily to change where your released ports/bottles live. You may also wish to store `ports.json` or `winecask.json` in a `docs/` folder. If you do, you will need to modify the YAML.
    - The workflows authenticate with the built-in `GITHUB_TOKEN` (granted `contents: write` in each workflow), so no Personal Access Token setup is required.
    - Pharos is designed with a one repository, one purpose rule. You should not mix ports with bottles or have a ports.json and winecask.json present in the same repository.
- `ports/` or `bottles/`
  - The centralized location for your ports/bottles. You can add subfolders for better organization, for example `released` and `WIP`.

## Optional PortMaster Integration

The Release Ports workflow also publishes a [PortMasterV3](https://portmaster.games/) catalog to the `ports-latest` release: a PortMaster-format `ports.json`, an `images.zip` of screenshots, and a `<name>.source.json` file. Users who copy that source file into their device's `PortMaster/config/` folder can browse and install your ports from stock PortMaster in addition to Pharos.

- The source file is generated automatically from your repository name. To customize the prefix or display name, commit your own `docs/<prefix>.source.json` and the workflow will upload that instead.
- Ports may declare runtimes via `attr.runtime` in `port.json` (e.g. `["weston_pack.squashfs"]`). Runtimes hosted by official PortMaster are referenced automatically. A custom runtime must be committed to a `runtimes/` folder (so the catalog can hash it) and uploaded as an asset on a `runtimes-latest` release.
- Bottles are Pharos-only; the PortMaster catalog covers ports.
- The step skips itself when `docs/ports.json` is empty, so bottles-only repositories are unaffected.

## Optional GitHub Pages

You can set up a GitHub pages website to display your releases in a user-friendly browser page. An example website backend exists at https://github.com/JeodC/RHH-Ports/tree/main/docs.

## Metadata

Your port will go through Pharos's autoinstaller, which means you can (and should) include metadata for maximum accessibility! Each port or bottle should be packaged like this:

```
Port/
  ├── port/
  │   ├── port.json         # REQUIRED
  │   ├── gameinfo.xml      # Optional metadata for EmulationStation
  │   ├── README.md         # Instructions
  │   ├── screenshot.png    # REQUIRED
  │   ├── cover.png         # Optional cover artwork
  │   └── other port files
  └── Port.sh
```

```
Bottle/
  ├── bottle/
  │   ├── bottle.json       # REQUIRED
  │   ├── gameinfo.xml      # Optional metadata for EmulationStation
  │   ├── README.md         # Instructions
  │   ├── screenshot.png    # REQUIRED
  │   ├── cover.png         # Optional cover artwork
  │   └── other bottle files
  └── Bottle.sh
```

Each port/bottle must have a `port.json`/`bottle.json` file and a screenshot in order to be validated as a port/bottle. Examples for each are included in this template repository.


## Use with Pharos

[Pharos App](https://github.com/JeodC/RHH-Ports/tree/main/ports/released/apps/pharos) is designed to link with github repositories matching the above structure. Once you've established your repository, add its URL to Pharos' `.sources` file and load the app to verify it works.
