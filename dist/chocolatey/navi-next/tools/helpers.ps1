### File inspired by https://github.com/chocolatey-community/chocolatey-packages/blob/master/automatic/firefox/tools/helpers.ps1

function AlreadyInstalled() {
    param(
        [Parameter(Mandatory = $true)]
        [string]$product,
        [Parameter(Mandatory = $true)]
        [string]$version
    )
    $uninstallEntry = $(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$product $version*"
    )
    $uninstallEntryWow64 = $(
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$product $version*"
    )

    if ((Test-Path $uninstallEntry) -or (Test-Path $uninstallEntryWow64)) {
        return $true
    }

    return $false
}