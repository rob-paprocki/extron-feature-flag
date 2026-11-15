#!/bin/sh
# Rebuild Extron.Features.Factory.dll per app, into dist/<AppKey>/. Uses
# `dotnet build` with the net472 reference-assembly pack (auto-restored)
# and the local Extron.Features.Contracts.dll from each app's install
# folder as the HintPath.
#
#   sh scripts/build.sh [root/of/Extron/folders]
#
# Default root: ~/Desktop/Extron
set -eu
ROOT="${1:-$HOME/Desktop/Extron}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$REPO/src/AllEnabledUserFeatures.cs"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

test -f "$SRC" || { echo "missing $SRC"; exit 1; }
command -v dotnet >/dev/null || { echo "dotnet not found; install the .NET SDK (6.0+)"; exit 1; }

built=0
for pair in "GCP:GCP" "GUIDesigner:GUI Designer" "Toolbelt:Toolbelt"; do
  dist="${pair%%:*}"
  app="${pair#*:}"
  src_app="$ROOT/$app"
  contracts="$src_app/Extron.Features.Contracts.dll"
  features="$src_app/Extron.Features.dll"
  [ -f "$contracts" ] && [ -f "$features" ] || { echo "skip $app (no Contracts/Features at $src_app)"; continue; }

  proj="$WORK/$dist"
  mkdir -p "$proj"
  cat > "$proj/Extron.Features.Factory.csproj" <<EOF
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net472</TargetFramework>
    <AssemblyName>Extron.Features.Factory</AssemblyName>
    <RootNamespace>Extron.Features.Factory</RootNamespace>
    <Deterministic>true</Deterministic>
    <AppendTargetFrameworkToOutputPath>false</AppendTargetFrameworkToOutputPath>
    <AssemblyVersion>5.4.0.0</AssemblyVersion>
    <FileVersion>5.4.0.0</FileVersion>
    <EnableDefaultCompileItems>false</EnableDefaultCompileItems>
  </PropertyGroup>
  <ItemGroup>
    <Compile Include="$SRC" />
    <Reference Include="System.ComponentModel.Composition" />
    <Reference Include="Extron.Features.Contracts">
      <HintPath>$contracts</HintPath>
      <Private>false</Private>
    </Reference>
  </ItemGroup>
</Project>
EOF
  echo ">> $app  Contracts $(sha256sum "$contracts" | cut -c1-12)"
  dotnet build "$proj/Extron.Features.Factory.csproj" -c Release -o "$proj/out" >/dev/null
  mkdir -p "$REPO/dist/$dist"
  cp "$proj/out/Extron.Features.Factory.dll" "$REPO/dist/$dist/Extron.Features.Factory.dll"
  echo "   -> $REPO/dist/$dist/Extron.Features.Factory.dll"
  built=$((built + 1))
done

[ "$built" -gt 0 ] || { echo "nothing built; no apps found under $ROOT"; exit 1; }
echo "done ($built built)."
