# Set parameters
[CmdletBinding()]
Param(
    $OutFile = "Array_Config.txt"
)

function WindowsBestPractices() {

    function Write-Log {
        [CmdletBinding()]
        param(
            [Parameter()][ValidateNotNullOrEmpty()][string]$Message,
            [Parameter()][ValidateNotNullOrEmpty()][ValidateSet("Information", "Passed", "Warning", "Failed")][string]$Severity = "Information"
        )
        [pscustomobject]@{
            Time     = (Get-Date -f g)
            Message  = $Message
            Severity = $Severity
        } | Out-File -FilePath $OutFile -Append
    }
    $compinfo = Get-SilComputer | Out-String -Stream
    $compinfo | Out-File -FilePath $OutFile -Append
    Write-Log -Message "Successfully retrieved computer properties. Continuing..." -Severity Information

     # Check for Multipath-IO
     if ((Get-WindowsFeature -Name 'Multipath-IO').InstallState -ne 'Installed') {
        Write-Log "MPIO Not Installed" -Severity Failed
        Write-Output "Installing MPIO" -ForegroundColor Red -NoNewline
        Add-WindowsFeature -Name Multipath-IO
        Write-Log "Installing MPIO" -Severity Information
        Write-Output "MPIO Installed, please restart"
    try {
        Write-Output "Restart is required, press enter to continue with reboot, or exit script to cancel"
        Pause
        Write-Output "Restarting Host, please run script again to verify all settings"
        Restart-Computer -Force
        Exit
    }
    catch {
Write-Output "Cannot Reboot computer"
Write-Log "Reboot Failed" -Severity Failed
    }
}
else {
    Write-Output "MPIO is installed"
}
    # Get MPIO Hardware Information
    $MPIOHardware = Get-MPIOAvailableHW
    $MPIOHardware | Out-File -FilePath $OutFile -Append
    Write-Output "Successfully retrieved MPIO Hardware. Continuing..."
    Write-Log -Message "Successfully retrieved MPIO Hardware. Continuing..." -Severity Information
    $MPIOHardware
    $DSMs = Get-MSDSMSupportedHW
if (($DSMs.VendorId -notcontains 'PURE') -and ($DSMs.ProductID -notcontains 'FlashArray')) {
    New-MSDSMSupportedHW -VendorId PURE -ProductId FlashArray
    Write-Output "Set MPIO Devices"
    Write-Log "Set MPIO Devices" -Severity Information
}
else {
    Write-Output "MPIO Devices are already set"
    Write-Log "MPIO Devices are already set" -Severity Information
} 
    # Set Variables
    $PendingReboot = "0"
    $MPIOSettings = $null
    $MPIOSettings = Get-MPIOSetting
    $PathVerificationState = $MPIOSettings.PathVerificationState
    $PDORemovePeriod = $MPIOSettings.PDORemovePeriod
    $UseCustomPathRecoveryTime = $MPIOSettings.UseCustomPathRecoveryTime
    $CustomPathRecoveryTime = $MPIOSettings.CustomPathRecoveryTime
    $DiskTimeOutValue = $MPIOSettings.DiskTimeoutValue
 
    # PathVerificationState
    if ($PathVerificationState -ne 'Enabled') {
        Write-Output "PathVerificationState is $PathVerificationState instead of Enabled."
        Write-Log -Message "PathVerificationState is $PathVerificationState." -Severity Failed
        Set-MPIOSetting -NewPathVerificationState Enabled | Out-Null
        $PendingReboot = "1"
    }
    else {
        Write-Output "PathVerificationState has a value of Enabled. No action required."
        Write-Log -Message "PathVerificationState has a value of Enabled. No action required." -Severity Passed
    }

    # PDORemovalPeriod
            if ($PDORemovePeriod -ne '30') {
                Write-Output "PDORemovePeriod is set to $PDORemovePeriod insteaed of 30."
                Write-Log -Message "PDORemovePeriod is set to $PDORemovePeriod instead of 30." -Severity Failed
                    Set-MPIOSetting -NewPDORemovePeriod 30
                    Write-Log -Message "PDORemovePeriod is set to $PDORemovePeriod." -Severity Information
                    $PendingReboot = "1"
                }
            else {
                    Write-Output "PDORemovePeriod is set to a value of 30. No action required."
                    Write-Log -Message "PDORemovePeriod is set to a value of 30. No action required." -Severity Passed
                }

    # PathRecoveryTime
    if ($UseCustomPathRecoveryTime -ne 'Enabled') {
        Write-Output "UseCustomPathRecoveryTime is set to $UseCustomPathRecoveryTime instead of Enabled."
        Write-Log -Message "UseCustomPathRecoveryTime is set to $UseCustomPathRecoveryTime instead of Enabled." -Severity Failed
            Set-MPIOSetting -CustomPathRecovery Enabled
            Write-Log -Message "UseCustomPathRecoveryTime is set to $UseCustomPathRecoveryTime." -Severity Information
            $PendingReboot = "1"
        }
    else {
        Write-Output "UseCustomPathRecoveryTime is set to Enabled. No action required."
        Write-Log -Message "UseCustomPathRecoveryTime is set to Enabled. No action required." -Severity Passed
    }

    # Custom Path Recovery Time
    if ($CustomPathRecoveryTime -ne '20') {
        Write-Output "CustomPathRecoveryTime is set to $CustomPathRecoveryTime instead of 20."
        Write-Log -Message "CustomPathRecoveryTime is set to $CustomPathRecoveryTime." -Severity Failed
            Set-MPIOSetting -NewPathRecoveryInterval 20
            Write-Log -Message "CustomPathRecoveryTime is set to $UseCustomPathRecoveryTime" -Severity Information
            $PendingReboot = "1"
        }
    else {
        Write-Output "CustomPathRecoveryTime is set to $CustomPathRecoveryTime. No action required."
        Write-Log -Message "CustomPathRecoveryTime is set to $CustomPathRecoveryTime. No action required." -Severity Passed
    }

    # DiskTimeOutValue
    if ($DiskTimeOutValue -ne '60') {
        Write-Output "DiskTimeOutValue is set to $DiskTimeOutValue instead of 60."
        Write-Log -Message "DiskTimeOutValue is set to $DiskTimeOutValue." -Severity Failed
            Set-MPIOSetting -NewDiskTimeout 60
            Write-Log -Message "DiskTimeOutValue is set to $DiskTimeOutValue." -Severity Information
            $PendingReboot = "1"
        }
    else {
        Write-Output "DiskTimeOutValue is set to $DiskTimeOutValue. No action required."
        Write-Log -Message "DiskTimeOutValue is set to $DiskTimeOutValue. No action required." -Severity Passed
    }

    # DisableDeleteNotification
    $DisableDeleteNotification = (Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\FileSystem' -Name 'DisableDeleteNotification')
    if ($DisableDeleteNotification.DisableDeleteNotification -ne 0) {
        Write-Output "DisableDeleteNotification is set to $DisableDeleteNotification instead of 0"
        Write-Log -Message "DiskDeleteNotification is set to $DiskTimeOutValue." -Severity Information
        Set-ItemProperty -Path'HKLM:\System\CurrentControlSet\Control\FileSystem' -Name 'DisableDeleteNotification' -Value '0'
        Write-Output "Delete Notification was Enabled"
        Write-Log -Message "Delete Notification was Enabled." -Severity Information
        $PendingReboot = "1"
    }
    else {
        Write-Output "Delete Notification is already enabled. No action required."
        Write-Log -Message "Delete Notification is already enabled. No action required." -Severity Passed
    }
    Write-Output "Pure Best Practices cmdlet has completed. The log file has been created for reference. Location: $OutFile" -ForegroundColor Green
    Write-Log -Message "Pure Best Practices cmdlet has completed." -Severity Information

    if ($PendingReboot -eq "1") {
        try {
            Write-Output "Restart is required, press enter to continue with reboot, or exit script to cancel"
            Pause
            Write-Output "Restarting Host, please run script again to verify all settings"
            Restart-Computer -Force
            Write-Log "Rebooting server" -Severity Information           
            Exit
        }
        catch {
    Write-Output "Cannot Reboot computer"
    Write-Log "Reboot Failed" -Severity Failed
        }
    }
    Pause
}
WindowsBestPractices ($Server)
#endregion
