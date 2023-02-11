# Base Sentinel Directory
$basePath = "C:\Program Files\SentinelOne\"

# Gets the folder based on the version of Sentinel installed
$sentinelDirectory = Get-ChildItem -Path $basePath -Directory

# Sets the Path Name from Folder Name
$sentinelName = $sentinelDirectory.Name

# Sets Full directory
$sentinelpath = "$basePath$sentinelName"

# Sets the location to run the command
Set-Location $sentinelPath

# Command to Check Certificate Scan status
$FDCSStatus = & ".\SentinelCtl.exe" read_fdcs_status

#Command to Check if Disk Scan is Running
$ScanStatus = & ".\SentinelCtl.exe" is_scan_in_progress

# If Certificate Scan Status is not 2 it will continue to check
if ($FDCSStatus -ne "FDCS Status: 2") {
    $timer = [Diagnostics.Stopwatch]::StartNew()
    do {
        Write-Host "Sentinel Scan is Running"
        Start-Sleep -Seconds 60
        $FDCSStatus = & ".\SentinelCtl.exe" read_fdcs_status
    } until ($FDCSStatus -eq "FDCS Status: 2")
}

# If Disk Scan Status is in progress it will continue to check
if ($ScanStatus -ne "Scan is not in progress") {
    $timer = [Diagnostics.Stopwatch]::StartNew()
    do {
        Write-Host "Sentinel Scan is Running"
        
        # Sleep timer between checks
        Start-Sleep -Seconds 60
        $ScanStatus = & ".\SentinelCtl.exe" is_scan_in_progress
    } until ($ScanStatus -eq "Scan is not in progress")
}

# Write the Output
Write-Host "Sentinel Scan is Complete"
if ($timer.IsRunning -eq $true) {
    $timer.Stop()
    $days = $timer.elapsed.Days
    $hours = $timer.elapsed.Hours
    $minutes = $timer.elapsed.Minutes
    $seconds = $timer.elapsed.Seconds
    if ($days -ne 0) {
        Write-Host "Sentinel Scan took $days days, $hours hours, $minutes minutes, $seconds seconds"
    }
    elseif ($hours -ne 0) {
        Write-Host "Sentinel Scan took $hours hours, $minutes minutes, $seconds seconds"
    }
    elseif ($minutes -ne 0) {
        Write-Host "Sentinel Scan took $minutes minutes, $seconds seconds"
    }
    else {
        Write-Host "Sentinel Scan took $seconds seconds"
    }
}
