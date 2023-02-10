# Base Sentinel Directory
$directory = "C:\Program Files\SentinelOne\"

# Gets the folder based on the version of Sentinel installed
$sentinelFolder = Get-ChildItem -Path $directory -Directory

# Sets the Path Name from Folder Name
$sentinelName = $sentinelFolder.Name

# Sets Full directory
$sentinelpath = "$directory$sentinelName"

# Sets the location to run the command
Set-Location $sentinelPath

# Command to Check Status
$sentinelStatus = & ".\SentinelCtl.exe" read_fdcs_status

# If Status is not 2 it will continue to check
if ($sentinelStatus -ne "FDCS Status: 2") {
    do {
        Write-Host "Sentinel Scan is Running"
        Start-Sleep -Seconds 60
    } until (
        $sentinelStatus -eq "FDCS Status: 2"
    )   
} 
Write-Host "Sentinel Scan is Complete"
