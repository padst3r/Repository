# === PARAMETERS ===
$newlanguage = "en-GB"                       # Set Language here -> https://learn.microsoft.com/en-us/linkedin/shared/references/reference-tables/language-codes
$TimeZoneToSet = "GMT Standard Time"   # Set Timezone here -> https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-time-zones?view=windows-11#time-zones
$geoid = "242"                               # Set Geo ID here -> https://learn.microsoft.com/en-us/windows/win32/intl/table-of-geographical-locations
# === END PARAMETERS ===

Set-ExecutionPolicy Unrestricted -Scope Process

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
Uninstall-Language en-US -Verbose
Start-Sleep -Seconds 30
Restart-Computer -Force
