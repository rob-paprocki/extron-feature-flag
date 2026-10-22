# Disclaimer

This repository ships a MEF plugin (`Extron.Features.Factory.dll`) that is
loaded by Extron's own `FeaturesProvider` composition mechanism in GCP,
GUI Designer, and Toolbelt. It is **add-only**: no file shipped by Extron
is modified, moved, replaced, or patched. Removing the dropped-in DLL
restores the install to its as-shipped state.

The repository is intended for use by **licensed users of the respective
Extron products**, running on installations they are authorized to
administer, for purposes of enabling the shipping Feature Flag Control
UI that Extron's own code implements but does not expose in the stock
menu layout.

The repository provides no license, right, or warranty with respect to
the underlying Extron software, Extron trademarks, or Extron
documentation. "Extron," "GCP," "Global Configurator Pro,"
"GUI Designer," and "Toolbelt" are referenced solely to identify the
target applications and are the property of their respective owner.

**No warranty.** The code and binaries here are provided as-is under the
MIT license. Running them against a given installation may interact in
unexpected ways with licensing, telemetry, or other subsystems, and may
be inconsistent with the terms of your license agreement with Extron.
You are responsible for determining whether, and under what conditions,
you may lawfully use this tooling on your own installations.

If you are not an authorized administrator of the target installation,
do not install this. If your license agreement forbids this class of
modification, do not install this. If you are unsure, ask Extron.
