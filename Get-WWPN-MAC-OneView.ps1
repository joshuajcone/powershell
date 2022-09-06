# This script will output the MAC's or WWPN's of all devices in OneView
# It outputs the .CSV to the running directory

# Checks if HPEOneView.630 module is installed, if not it installs it.
# Will install over top of different versions, remove "-AllowClobber" on line 10 to remove this.
if (Get-Module -ListAvailable -Name HPEOneView.630) {
    Write-Host "HPEOneView.630 Module exists"
} 
else {
    Install-Module -Name HPEOneView.630 -AllowClobber
    Write-Host "HPEOneView.630 Module Installed"
}

# Connect to OneView
$MyOneView=Read-Host -Prompt "Enter OneView FQDN or IP"
$MyOneViewCredential=Get-Credential
Connect-OVMgmt -Hostname $MyOneView -Credential $MyOneViewCredential

$servers = Get-OVServer

$serverArray = @()

foreach ($server in $servers) {

    $devices = $server.portMap.deviceSlots

      foreach ($device in $devices) {
         # Remove the "#" from the line 32 to output the device name if you need to update
         # If device name needs updated, update the "'" entry on line 34
         # If MAC address is needed instead of WWPN, add "#" to lines 39 & 40, remove "#" from lines 41 & 42

         #Write-Host $device.deviceName

         if ($device.deviceName -eq "HPE StoreFabric SN1600E 32Gb Dual Port Fibre Channel Host Bus Ad")
         {
            $obj = [PSCustomObject]@{
               Server    = $server.name
               SerialNo  = $server.serialNumber
               Port1_WWN = $device.physicalPorts[0].wwn
               Port2_WWN = $device.physicalPorts[1].wwn
               #Port1_MAC = $device.physicalPorts[0].mac
               #Port2_MAC = $device.physicalPorts[1].mac
         }


         $serverArray += $obj
      }
   }
}
   $serverArray | foreach-object { [PSCustomObject]$_ } | Format-Table -AutoSize

   $OutFile = $PSScriptRoot + '\WWN-MAC_out.csv'

   $serverArray | Export-Csv -Path $OutFile -NoTypeInformation

Disconnect-OVMgmt
