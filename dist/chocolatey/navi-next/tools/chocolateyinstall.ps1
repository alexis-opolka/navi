$ErrorActionPreference = 'Stop'

$toolsPath = Split-Path $MyInvocation.MyCommand.Definition
. $toolsPath\helpers.ps1

### Metadata related to the software and package
$packageName = 'navi'
$softwareName = 'navi-next'
$version = '2.24.0-alpha1'

$alreadyInstalled = (AlreadyInstalled -product $softwareName -version $version)

$installPath = Get-ChocolateyPath -PathType 'PackagePath'

Write-Output "Path: $installPath"

if ($alreadyInstalled -and !$env:ChocolateyForce) {
  Write-Output $(
  "navi-next is already installed. " +
          'No need to download and re-install.'
  )
  exit
}

### We're checking to see if we have never installed navi before
if (-Not(Test-Path $installPath)) {
  New-Item -Path $installPath
} else {
  ### Otherwise, we delete possible old versions
  Get-ChildItem $installPath\* | ? { $_.PSISContainer } | Remove-Item -Recurse -Force
}


$packageArgs = @{
  packageName    = $packageName
  fileType       = 'exe'
  softwareName   = "$softwareName*"
  Checksum       = $checksum
  ChecksumType   = 'sha512'
  Url            = "https://github.com/alexis-opolka/navi/releases/download/v$version/navi-v$version-x86_64-pc-windows-gnu.zip"
  silentArgs     = "$sa /S"
  validExitCodes = @(0)
}

Move-Item "$env:SystemDrive\tools\navi-next\navi" "$installPath\navi\navi"
Install-ChocolateyPath -PathToInstall "$installPath"
