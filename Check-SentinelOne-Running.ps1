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

# Command to Check Status FDCS status
$FDCSStatus = & ".\SentinelCtl.exe" read_fdcs_status

#Comman to Check if Scan is Running
$ScanStatus = & ".\SentinelCtl.exe" is_scan_in_progress

# If Status is not 2 it will continue to check
if ($FDCSStatus -ne "FDCS Status: 2") {
    $timer = [Diagnostics.Stopwatch]::StartNew()
    do {
        Write-Host "Sentinel Scan is Running"
        Start-Sleep -Seconds 60
        $FDCSStatus = & ".\SentinelCtl.exe" read_fdcs_status
    } until ($FDCSStatus -eq "FDCS Status: 2")
}
if ($ScanStatus -ne "Scan is not in progress") {
    $timer = [Diagnostics.Stopwatch]::StartNew()
    do {
        Write-Host "Sentinel Scan is Running"
        Start-Sleep -Seconds 60
        $ScanStatus = & ".\SentinelCtl.exe" is_scan_in_progress
    } until ($ScanStatus -eq "Scan is not in progress")
}
Write-Host "Sentinel Scan is Complete"
if ($null -ne $timer) {
    $timer.Stop()
    $hours = $timer.elapsed.hours
    $minutes = $timer.elapsed.minutes
    $seconds = $timer.elapsed.seconds
    Write-Host "Sentinel Scan took $hours hours, $minutes minutes, $seconds seconds"
}
