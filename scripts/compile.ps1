param([string]$ProjectPath = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
$extensions = Join-Path $env:USERPROFILE '.vscode\extensions'
$extension = Get-Item -LiteralPath (Join-Path $extensions 'juliacomputing.dyad-studio-3.5.1') -ErrorAction SilentlyContinue
if (!$extension) { throw 'Dyad Studio 3.5.1 was not found. Install version 3.5.1 in VS Code Extensions.' }
$package = Get-Content -LiteralPath (Join-Path $extension.FullName 'package.json') -Raw | ConvertFrom-Json
if ($package.version -ne '3.5.1') { throw 'The selected extension is not Dyad Studio 3.5.1.' }
Write-Host "Dyad Studio $($package.version); bundled CLI $($package.dependencies.'@juliacomputing/dyad-cli'); kernel $($package.dependencies.'@juliacomputing/dyad-kernel')"
$cli = Join-Path $extension.FullName 'out\dyad-cli.js'
$node = Get-Command node -ErrorAction SilentlyContinue
$savedElectron = $env:ELECTRON_RUN_AS_NODE
try {
    if ($node) {
        & $node.Source $cli compile $ProjectPath
    } else {
        $code = Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\Code.exe'
        if (!(Test-Path -LiteralPath $code)) { throw 'Install Node.js or use Dyad: Compile in VS Code.' }
        $env:ELECTRON_RUN_AS_NODE = '1'
        & $code $cli compile $ProjectPath | Out-Host
    }
    if ($LASTEXITCODE -ne 0) { throw "Dyad compilation failed ($LASTEXITCODE)." }
} finally {
    $env:ELECTRON_RUN_AS_NODE = $savedElectron
}
