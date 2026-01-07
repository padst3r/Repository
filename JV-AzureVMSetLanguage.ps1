# Justin Verstijnen AzureVM Set Language Script
# Github page: https://github.com/JustinVerstijnen/JV-AzureVMSetLanguage
# Let's start!
Write-Host "Script made by..." -ForegroundColor DarkCyan
Write-Host "     _           _   _        __     __            _   _  _                  
    | |_   _ ___| |_(_)_ __   \ \   / /__ _ __ ___| |_(_)(_)_ __   ___ _ __  
 _  | | | | / __| __| | '_ \   \ \ / / _ \ '__/ __| __| || | '_ \ / _ \ '_ \ 
| |_| | |_| \__ \ |_| | | | |   \ V /  __/ |  \__ \ |_| || | | | |  __/ | | |
 \___/ \__,_|___/\__|_|_| |_|    \_/ \___|_|  |___/\__|_|/ |_| |_|\___|_| |_|
                                                       |__/                  " -ForegroundColor DarkCyan
                                                       
# === PARAMETERS ===
$newlanguage = "en-GB"                       # Set Language here -> https://learn.microsoft.com/en-us/linkedin/shared/references/reference-tables/language-codes
$TimeZoneToSet = "GMT Standard Time"   # Set Timezone here -> https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-time-zones?view=windows-11#time-zones
$geoid = "242"                               # Set Geo ID here -> https://learn.microsoft.com/en-us/windows/win32/intl/table-of-geographical-locations
# === END PARAMETERS ===

Set-ExecutionPolicy Unrestricted -Scope Process

# Step 1: First check if the script runs as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Warning "This script must be runned as Administrator. The script will now end."
    exit
}


# Step 2: Getting current installed language
$oldlanguage = Get-SystemPreferredUILanguage
Write-Host "The current language is: $oldlanguage"
Write-Host "The new language will become: $newlanguage"


# Step 3: Installing new language pack
Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue "Language $newlanguage will be installed. This can take up to 20 minutes..."
Install-Language $newlanguage -Verbose
Write-Host -ForegroundColor Green -BackgroundColor DarkBlue "Language $newlanguage is successfully installed."


# Step 4: Changing system language to newly installed language
Set-SystemPreferredUILanguage $newlanguage -Verbose
Set-WinUILanguageOverride -Language $newlanguage -Verbose
Set-WinSystemLocale $newlanguage -Verbose
Set-Culture $newlanguage
Set-WinHomeLocation -GeoId $geoid


# Step 5: Sets new Timezone
Set-Timezone -Id $TimeZoneToSet


# Step 6: Set new language for all current and new users and language bar settings
Copy-UserInternationalSettingsToSystem -WelcomeScreen $True -NewUser $True -Verbose
Set-WinLanguageBarOption -UseLegacySwitchMode -UseLegacyLanguageBar


# Step 7: Removing old language and rebooting VM to apply settings
Uninstall-Language $oldlanguage -Verbose
Write-Host -ForegroundColor Green -BackgroundColor Green "The language is now set to: $newlanguage"
Write-Host -ForegroundColor Green -BackgroundColor Yellow "The VM will be restarted in 30 seconds."
Start-Sleep -Seconds 30
Restart-Computer -Force
