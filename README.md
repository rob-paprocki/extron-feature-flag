# extron-feature-flag

Shows the hidden Feature Flag Control menu in Extron GCP, GUI Designer, and
Toolbelt so you can toggle feature flags (CPU and memory meter, debug
options, diagnostic flags) through the shipping `FeatureFlagControlWindow`
UI. Add-only: nothing Extron ships is modified.

> Authorized-use only. See [DISCLAIMER.md](DISCLAIMER.md).

## Coverage

| Product | Contracts ver. | Deliverable |
|---|---|---|
| **GCP** (Global Configurator Pro) | 5.4.0.0 | `dist/GCP/Extron.Features.Factory.dll` |
| **GUI Designer** | 5.4.0.0 | `dist/GUIDesigner/Extron.Features.Factory.dll` |
| **Toolbelt** | 5.4.0.0 | `dist/Toolbelt/Extron.Features.Factory.dll` |

In GUI Designer the item lives under a top-level Debug menu whose visibility
is reconciled on `LicenseInfoChanged`; open the licensing dialog once
after first launch and both the Debug menu and its Feature Flag Control
child will appear. GCP and Toolbelt place the item under Tools on next
launch.

## How it works

`Extron.Features.dll::FeaturesProvider._Compose()` MEF-loads a sibling
`Extron.Features.Factory.dll` from the install folder with no strong-name,
Authenticode, or whitelist check. The dropped-in Factory exports
`[Export(typeof(IUserFeatures))] AllEnabledUserFeatures`, whose indexer
`this[flagName] => true` satisfies the gate
`if (FeaturesProvider.instance["show-user-accessible-flags"]) { addMenuItem(); }`
in each product's menu builder.

All three products ship `Extron.Features.Contracts v5.4.0.0` with the
same `IUserFeatures` interface, so one source file
([`src/AllEnabledUserFeatures.cs`](src/AllEnabledUserFeatures.cs)) rebuilt
per app produces three semantically identical DLLs. They are
interchangeable; the per-app `dist/` folders exist only so you can tell
which install produced each one.

## Requirements

- GCP, GUI Designer or Toolbelt at the Contracts version in the table above.
- A POSIX shell for the scripts, such as Git Bash on Windows. Or skip the
  script and copy each `dist/<App>/Extron.Features.Factory.dll` into that
  app's install folder by hand.
- To rebuild the DLLs, which is optional: a .NET SDK 6.0 or later, and each
  app's own `Extron.Features.Contracts.dll` and `Extron.Features.dll`.

There is nothing to configure. The scripts' only argument is the folder that
holds the `GCP`, `GUI Designer` and `Toolbelt` app folders.

## Install

Exit each app fully first. It reads the Factory once, on the first feature
flag it checks, so a running app will not see the DLL.

```sh
sh scripts/install.sh                            # defaults to ~/Desktop/Extron
sh scripts/install.sh /path/to/Extron/root       # explicit root
```

The script copies the prebuilt Factory DLL into each app folder it finds
under the given root. On Windows the apps are usually under
`C:\Program Files (x86)\Extron\`, which needs an elevated shell to write to.
A DLL that arrived over SMB or a browser download must be unblocked first
(see [Notes](#notes)).

## Build (optional, DLLs are prebuilt in `dist/`)

```sh
sudo apt-get install -y dotnet-sdk-6.0   # or any .NET SDK that targets net472
sh scripts/build.sh                      # scans ~/Desktop/Extron
sh scripts/build.sh /path/to/Extron/root
```

The build uses `dotnet build` with the net472 reference-assembly pack
(auto-restored) and the local `Extron.Features.Contracts.dll` from each
app's install folder as the reference. Output lands in `dist/<AppKey>/`.

## Revert

```sh
rm /path/to/Extron/{GCP,GUI Designer,Toolbelt}/Extron.Features.Factory.dll
```

## Notes

Windows attaches a Mark of the Web stream to files that arrive over SMB
or through a browser download. After transferring the DLL to a Windows
install, unblock it (right-click, Properties, Unblock) or
`AssemblyCatalog` silently throws `FileLoadException` and the menu will
not appear.

Composition is one-shot: `FeaturesProvider._didCompose` latches true in
a `finally` block on first flag access, which is why the app has to be
closed during the install.

A stale `features.json` under
`%PUBLIC%\Documents\Extron\Features\<App>\<version>\` can suppress the
menu even after the Factory loads. Delete the file by hand if the menu
still doesn't appear.

Not covered by this repo: **GlobalScripter** (different Contracts ABI
and a native authorization pre-gate), **Extron PCS** (no Features
subsystem), and **ControlScript Deployment Utility** (Electron app with
a native license addon).

## License

[MIT](LICENSE). See also [DISCLAIMER.md](DISCLAIMER.md).
