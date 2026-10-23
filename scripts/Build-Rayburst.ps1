Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$sourceRoot = Join-Path $repoRoot 'upstream'
$targetTriple = $env:TARGET_TRIPLE
$outputArch = $env:OUTPUT_ARCH
$version = if ($env:RAYBURST_VERSION) { $env:RAYBURST_VERSION } else { '4.1.0' }
$expectedCommit = 'e8173d6d5b47576309e434150192b2a1649a4110'

if ($targetTriple -notin @('x86_64-pc-windows-msvc', 'aarch64-pc-windows-msvc')) {
    throw "Unsupported TARGET_TRIPLE: $targetTriple"
}
if ($outputArch -notin @('x64', 'arm64')) {
    throw "Unsupported OUTPUT_ARCH: $outputArch"
}
if (-not (Test-Path (Join-Path $sourceRoot 'src-tauri\Cargo.toml'))) {
    throw 'Rayburst source submodule is missing. Run git submodule update --init --recursive.'
}

$checkedOutCommit = (& git -C $sourceRoot rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or $checkedOutCommit -ne $expectedCommit) {
    throw "Expected pinned Rayburst commit $expectedCommit; found $checkedOutCommit."
}

$tauriRoot = Join-Path $sourceRoot 'src-tauri'
$payloadDir = Join-Path $repoRoot "artifacts\payload\$outputArch"
$installerDir = Join-Path $repoRoot 'artifacts\installer'
if (Test-Path $payloadDir) { Remove-Item $payloadDir -Recurse -Force }
New-Item -ItemType Directory -Path $payloadDir -Force | Out-Null
New-Item -ItemType Directory -Path $installerDir -Force | Out-Null

Push-Location $sourceRoot
try {
    pnpm install --frozen-lockfile
    if ($LASTEXITCODE -ne 0) { throw "pnpm install failed with exit code $LASTEXITCODE." }

    # Pass the target triple into Rayburst's own pre-build script. It builds
    # the native messaging host for the selected architecture.
    $env:TAURI_ENV_TARGET_TRIPLE = $targetTriple
    pnpm tauri build --target $targetTriple --no-bundle --config src-tauri/tauri.release.json
    if ($LASTEXITCODE -ne 0) { throw "Rayburst build failed with exit code $LASTEXITCODE." }
}
finally {
    Pop-Location
}

$requiredFiles = @(
    @{ Source = (Join-Path $tauriRoot "target\$targetTriple\release\rayburst.exe"); Destination = 'Rayburst.exe' },
    @{ Source = (Join-Path $tauriRoot "binaries\aria2-next-$targetTriple.exe"); Destination = 'aria2-next.exe' },
    @{ Source = (Join-Path $tauriRoot "generated-binaries\rayburst-browser-launcher-$targetTriple.exe"); Destination = 'rayburst-browser-launcher.exe' },
    @{ Source = (Join-Path $sourceRoot 'LICENSE'); Destination = 'LICENSE-Rayburst.txt' },
    @{ Source = (Join-Path $tauriRoot 'icons\icon.ico'); Destination = 'icon.ico' }
)
foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file.Source -PathType Leaf)) {
        throw "Required build output or source asset is missing: $($file.Source)"
    }
    Copy-Item -LiteralPath $file.Source -Destination (Join-Path $payloadDir $file.Destination) -Force
}

$resourcePaths = @(
    'data\ed2k-bootstrap\server.met',
    'data\ed2k-bootstrap\nodes.dat',
    'data\bt-peer-blocklist.txt',
    'data\dbip-country-lite.mmdb',
    'native-messaging\manifests\chromium.json',
    'native-messaging\manifests\firefox.json'
)
foreach ($relativePath in $resourcePaths) {
    $sourcePath = Join-Path $tauriRoot $relativePath
    if (-not (Test-Path $sourcePath -PathType Leaf)) {
        throw "Required Rayburst resource is missing: $sourcePath"
    }
    $destinationPath = Join-Path $payloadDir $relativePath
    New-Item -ItemType Directory -Path (Split-Path $destinationPath -Parent) -Force | Out-Null
    Copy-Item -LiteralPath $sourcePath -Destination $destinationPath -Force
}

Copy-Item -LiteralPath (Join-Path $repoRoot 'THIRD-PARTY-NOTICES.md') -Destination (Join-Path $payloadDir 'THIRD-PARTY-NOTICES.txt') -Force

# Run ISCC from the repository root; the script picks up the verified payload
# through environment variables so paths with spaces remain safe.
$env:RAYBURST_PAYLOAD_DIR = $payloadDir
$env:RAYBURST_VERSION = $version
$env:RAYBURST_ARCH = $outputArch
$env:RAYBURST_OUTPUT = $outputArch
$iscc = Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 6\ISCC.exe'
if (-not (Test-Path $iscc)) { throw "Inno Setup compiler was not found at $iscc" }

Push-Location $repoRoot
try {
    & $iscc 'installer\Rayburst.iss'
    if ($LASTEXITCODE -ne 0) { throw "Inno Setup compile failed with exit code $LASTEXITCODE." }
}
finally {
    Pop-Location
}

$installerPath = Join-Path $installerDir "Rayburst-$version-Setup-$outputArch.exe"
if (-not (Test-Path $installerPath -PathType Leaf)) {
    throw "Expected installer was not produced: $installerPath"
}
$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $installerPath).Hash
Write-Host "Created $installerPath"
Write-Host "SHA-256: $hash"
