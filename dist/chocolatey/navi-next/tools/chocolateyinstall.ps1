$ErrorActionPreference = 'Stop'

$toolsPath = Split-Path $MyInvocation.MyCommand.Definition
. $toolsPath\helpers.ps1

### Metadata related to the software and package
$packageName = 'navi'
$softwareName = 'navi-next'
$version = '2.24.0-alpha1-security-fix'

$alreadyInstalled = (AlreadyInstalled -product $softwareName -version $version)
$installPath = Get-ChocolateyPath -PathType 'PackagePath'

Write-Output $installPath

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

# Download from an HTTPS location
Get-ChocolateyWebFile -PackageName "$packageName" -FileFullPath "$toolsPath\$softwareName.zip" -Url "https://github.com/alexis-opolka/navi/releases/download/v$version/navi-v$version-x86_64-pc-windows-gnu.zip"
Get-ChocolateyUnzip -FileFullPath "$toolsPath\$softwareName.zip" -Destination $toolsPath
Install-ChocolateyPath -PathToInstall $toolsPath
