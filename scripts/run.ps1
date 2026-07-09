param(
    [Parameter(Position = 0)]
    [string[]]$DeviceArgs
)

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

$flutterArgs = @("run") + $DeviceArgs

& flutter @flutterArgs
