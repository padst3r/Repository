<#Author       : Akash Chawla
# Usage        : Windows optimizations for AVD
#>

#############################################
#         Windows optimizations             #
#############################################

# Inspired by and referenced: https://raw.githubusercontent.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/main/Windows_VDOT.ps1

$Optimizations = "DefaultUserSettings"
$WorkingLocation = (Join-Path $PSScriptRoot $WindowsVersion)

     #region Customize Default User Profile
    # Apply appearance customizations to default user registry hive, then close hive file

        $DefaultUserSettingsFilePath = Join-Path -Path $WorkingLocation -ChildPath 'DefaultUserSettings.json'
        $DefaultUserSettingsUrl = "https://raw.githubusercontent.com/padst3r/Repository/refs/heads/master/DefaultUserSettings.json"

        Invoke-WebRequest $DefaultUserSettingsUrl -OutFile $DefaultUserSettingsFilePath -UseBasicParsing

        If (Test-Path $DefaultUserSettingsFilePath)
        {
            Write-Host "AVD AIB Customization : Windows Optimizations - - Set Default User Settings"
            $UserSettings = (Get-Content $DefaultUserSettingsFilePath | ConvertFrom-Json).Where( { $_.SetProperty -eq $true })
            If ($UserSettings.Count -gt 0)
            {
                Write-Host "AVD AIB Customization : Windows Optimizations - Processing Default User Settings (Registry Keys)" 
                $null = Start-Process reg -ArgumentList "LOAD HKLM\VDOT_TEMP C:\Users\Default\NTUSER.DAT" -PassThru -Wait
                # & REG LOAD HKLM\VDOT_TEMP C:\Users\Default\NTUSER.DAT | Out-Null

                Foreach ($Item in $UserSettings)
                {
                    If ($Item.PropertyType -eq "BINARY")
                    {
                        $Value = [byte[]]($Item.PropertyValue.Split(","))
                    }
                    Else
                    {
                        $Value = $Item.PropertyValue
                    }

                    If (Test-Path -Path ("{0}" -f $Item.HivePath))
                    {
                        Write-Host "AVD AIB Customization : Windows Optimizations - Found $($Item.HivePath) - $($Item.KeyName)"

                        If (Get-ItemProperty -Path ("{0}" -f $Item.HivePath) -ErrorAction SilentlyContinue)
                        {
                            Write-Host "AVD AIB Customization : Windows Optimizations - Set $($Item.HivePath) - $Value"
                            Set-ItemProperty -Path ("{0}" -f $Item.HivePath) -Name $Item.KeyName -Value $Value -Type $Item.PropertyType -Force 
                        }
                        Else
                        {
                            Write-Host "AVD AIB Customization : Windows Optimizations- New $($Item.HivePath) Name $($Item.KeyName) PropertyType $($Item.PropertyType) Value $Value"
                            New-ItemProperty -Path ("{0}" -f $Item.HivePath) -Name $Item.KeyName -PropertyType $Item.PropertyType -Value $Value -Force | Out-Null
                        }
                    }
                    Else
                    {
                        Write-Host "AVD AIB Customization : Windows Optimizations- Registry Path not found $($Item.HivePath)" 
                        Write-Host "AVD AIB Customization : Windows Optimizations- Creating new Registry Key $($Item.HivePath)"
                        $newKey = New-Item -Path ("{0}" -f $Item.HivePath) -Force
                        If (Test-Path -Path $newKey.PSPath)
                        {
                            New-ItemProperty -Path ("{0}" -f $Item.HivePath) -Name $Item.KeyName -PropertyType $Item.PropertyType -Value $Value -Force | Out-Null
                        }
                        Else
                        {
                            Write-Host "AVD AIB Customization : Windows Optimizations- Failed to create new Registry Key" 
                        } 
                    }
                }
                $null = Start-Process reg -ArgumentList "UNLOAD HKLM\VDOT_TEMP" -PassThru -Wait
                # & REG UNLOAD HKLM\VDOT_TEMP | Out-Null
            }
            Else
            {
                Write-Host "AVD AIB Customization : Windows Optimizations- No Default User Settings to set" 
            }
        }
        Else
        {
            Write-Host "AVD AIB Customization : Windows Optimizations- File not found: $DefaultUserSettingsFilePath"
        }    
