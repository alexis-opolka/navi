### This script installs the Powershell module under the user's Powershell modules path
### For modifications of the Powershell Navi plugin, see /shell/navi.plugin/navi.plugin.psm1.

param (    
    ### Controls if we update the current module (otherwise we don't rewrite the already existing module, if present)
    [Switch]$Update,
    ### Should the verbosity be enabled?
    [Switch]$Verbose
)


function InstallNaviWidgetModule(){
    [String]$NAVI_PLUGIN = "navi.plugin";

    Write-Debug "Are we updating the PowerShell module: $Update"

    ### If we're updating the module, Copy the newly updated contents to the currently installed module
    ### then quit with a successful exit code.
    ### We're not supposed to update the shortcut binding.
    if ($Update){
        Write-Debug "Updating Navi-Widget PowerShell module"
         Install-Module -Name navi.plugin
        exit 0
    }

    ### If we're not updating, check if we don't have the module already installed
    if (-Not (Test-Path -Path $PwshModulePath\$NAVI_PLUGIN)) {
        Write-Debug "Copying Item to the path"
         Install-Module -Name navi.plugin
    } else {
        Write-Error "Navi-Widget is already installed for PowerShell!"
        exit 1
    }

    ### We first need to be sure the profile has been created
    if (-Not(Test-Path -Path $PROFILE)) {
        ### The Profile file hasn't been created yet
        New-Item -ItemType "file" -Path $PROFILE -Force
    }

    Write-Debug "Registering the navi shortcut inside the current shell session"
    Set-PSReadlineKeyHandler -BriefDescription "A keybinding to open Navi Widget" -Chord Ctrl+g -ScriptBlock { Invoke-NaviWidget }

    Write-Debug "Appending the navi shortcut inside the current user's profile"
    ### Adding a new line
    Write-Output "Import-Module navi.plugin" >> $PROFILE
    Write-Output "" >> $PROFILE
    Write-Output 'Set-PSReadlineKeyHandler -BriefDescription "A keybinding to open Navi Widget" -Chord Ctrl+g -ScriptBlock { Invoke-NaviWidget }' >> $PROFILE


    Write-Output "Navi plugin has been installed!"
    exit 0 ### Succesful installation
}

if ($Verbose) {
    ### Enabling verbose/debug output at the start of the script
    $DebugPreference = 'Continue'
    InstallNaviWidgetModule -Update $Update
    ### Disabling verbose/debug output at the end of the script
    ### in order to not modify the current user's shell environment
    $DebugPreference = 'SilentlyContinue'
} else {
    InstallNaviWidgetModule -Update $Update
}
