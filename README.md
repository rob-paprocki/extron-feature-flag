# extron-feature-flag

Adds one DLL to Extron's Global Configurator Pro, GUI Designer and Toolbelt so their hidden Feature Flag Control menu shows up. Nothing Extron ships is modified.

[![Release](https://img.shields.io/github/v/release/rob-paprocki/extron-feature-flag)](https://github.com/rob-paprocki/extron-feature-flag/releases)
[![CI](https://github.com/rob-paprocki/extron-feature-flag/actions/workflows/ci.yml/badge.svg)](https://github.com/rob-paprocki/extron-feature-flag/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/github/license/rob-paprocki/extron-feature-flag)](LICENSE)
[![Last commit](https://img.shields.io/github/last-commit/rob-paprocki/extron-feature-flag)](https://github.com/rob-paprocki/extron-feature-flag/commits/main)

> [!WARNING]
> For licensed Extron users on installations they administer. Read [DISCLAIMER.md](DISCLAIMER.md) first.

## Why

- Toggle the app's own feature flags (CPU and memory meter, debug options, diagnostic flags) from its `FeatureFlagControlWindow`.
- Add-only: you copy one file per app, and deleting it puts the install back as shipped.
- Prebuilt DLLs are in `dist/`, with the single C# source in `src/`.

**Not supported:** GlobalScripter, Extron PCS (no Features subsystem) and the ControlScript Deployment Utility (an Electron app with a native license addon).

## Requirements

| Item | Needed |
|---|---|
| Apps | GCP, GUI Designer or Toolbelt with `Extron.Features.Contracts` 5.4.0.0 |
| OS | Windows for the apps; a POSIX shell such as Git Bash for the scripts, or copy the DLL by hand |
| To rebuild | .NET SDK (6.0 or later) with the net472 reference pack, which `dotnet build` restores itself |

## Install

```sh
sh scripts/install.sh                         # defaults to ~/Desktop/Extron
sh scripts/install.sh /path/to/Extron/root    # explicit root
```

The script copies the matching DLL into each app folder it finds under the root. If the apps are under Program Files, run it from an elevated shell or copy the DLL by hand. Then start the app and look for Tools > Feature Flag Control.

GUI Designer puts the item under a top-level Debug menu that only appears after a license-info change. Open the licensing dialog once, or sign out and back in, and look again.

## Quick start

1. Exit the app completely. Composition happens once per launch.
2. Run the install script as above.
3. Unblock the DLL if it came over SMB or a browser download (right-click, Properties, Unblock). Without that, `AssemblyCatalog` throws `FileLoadException` and the menu never appears.
4. Launch the app and open Tools > Feature Flag Control.

To undo it, delete the file:

```sh
rm /path/to/Extron/{GCP,"GUI Designer",Toolbelt}/Extron.Features.Factory.dll
```

## Coverage

| Product | Contracts version | Deliverable |
|---|---|---|
| GCP (Global Configurator Pro) | 5.4.0.0 | `dist/GCP/Extron.Features.Factory.dll` |
| GUI Designer | 5.4.0.0 | `dist/GUIDesigner/Extron.Features.Factory.dll` |
| Toolbelt | 5.4.0.0 | `dist/Toolbelt/Extron.Features.Factory.dll` |

## How it works

`Extron.Features.dll` loads a sibling `Extron.Features.Factory.dll` from the install folder through MEF, with no strong-name, Authenticode or whitelist check. The DLL here exports an `IUserFeatures` whose indexer returns `true` for every flag name. That satisfies the check
`FeaturesProvider.instance["show-user-accessible-flags"]` that each app's menu builder makes before it adds the menu item.

All three apps ship the same `IUserFeatures` interface in Contracts 5.4.0.0. One source file, [`src/AllEnabledUserFeatures.cs`](src/AllEnabledUserFeatures.cs), is built once per app against that app's own `Extron.Features.Contracts.dll`. The three DLLs behave the same, and the per-app folders in `dist/` only tell you which install produced which file.

## Build

The DLLs in `dist/` are prebuilt. To rebuild them against your own installs:

```sh
sh scripts/build.sh                         # scans ~/Desktop/Extron
sh scripts/build.sh /path/to/Extron/root
```

Output lands in `dist/<AppKey>/`.

<details>
<summary>Notes and troubleshooting</summary>

- Composition is one-shot: `FeaturesProvider._didCompose` latches true in a `finally` block on the first flag access. Exit the app fully before you install the DLL.
- A stale `features.json` under `%PUBLIC%\Documents\Extron\Features\<App>\<version>\` can hide the menu even after the Factory loads. Delete it by hand if the menu still doesn't show.
- Extron updates can change the Contracts version. These DLLs are built for 5.4.0.0 and need a rebuild if an update changes it.

</details>

## Help

Questions and bug reports go in [Issues](https://github.com/rob-paprocki/extron-feature-flag/issues).

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

[MIT](LICENSE) (c) 2026 rob-paprocki. See also [DISCLAIMER.md](DISCLAIMER.md).
