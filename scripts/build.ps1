param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet("apk", "appbundle", "ios", "ipa")]
    [string]$Target
)

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

switch ($Target) {
    "apk" { & flutter build apk --release }
    "appbundle" { & flutter build appbundle --release }
    "ios" { & flutter build ios --release }
    "ipa" { & flutter build ipa --release }
}
