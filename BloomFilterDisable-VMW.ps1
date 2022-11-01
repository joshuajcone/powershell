# Supply the hostname/FQDN for your vcenter server, and the name of the cluster you want remediated
# Script remediates each ESXi server in the cluster one at a time
# Example ".\nameofthisscript.ps1 vcenter.test.com testcluster"

# Args
# Check to make sure an argument was passed
if ($args.count -ne 2) {
Write-Host "Usage: .\nameofthisscript.ps1 vcenter.test.com testcluster"
exit
}

# Set vCenter and Cluster name from Arg
$vCenterServer = $args[0]
$ClusterName = $args[1]

# Connect to infrastructure

Connect-VIServer -Server $vCenterServer | Out-Null

# Get Server Objects from the cluster

# Get VMware Server Object based on name passed as arg
$ESXiServers = @(get-cluster $ClusterName | get-vmhost)
    
    # Puts an ESXI server in maintenance mode, changes the Bloom setting, and the puts it back online
    # Requires fully automated DRS and enough HA capacity to take a host off line
    
    Function BloomFilter ($CurrentServer) {
        # Get Server name
        $ServerName = $CurrentServer.Name

        # Check Bloom Status
        $esxcli = Get-EsxCli -VMHost $ServerName -V2
        $result = $esxcli.system.settings.advanced.list.Invoke(@{option = '/SE/BFEnabled'})
        if($result.intvalue -ne 0){
           
            # Put server in maintenance mode
            Write-Host "#### Maintenance Mode $ServerName ####"
            Set-VMhost $CurrentServer -State maintenance -Evacuate | Out-Null
            Write-Host "$ServerName is in Maintenance Mode"
    
            # Apply Bloom filter setting
            Write-Host "Apply Bloom"
            $esxcli = Get-EsxCli -VMHost $ServerName -V2
            $result = $esxcli.system.settings.advanced.list.Invoke(@{option = '/SE/BFEnabled'})
            if($result.intvalue -ne 0){
            $esxcli.system.settings.advanced.set.Invoke((@{option = '/SE/BFEnabled'; intvalue = 0 }))
            }
            # Exit maintenance mode
            Write-Host "Exiting Maintenance mode"
            Set-VMhost $CurrentServer -State Connected | Out-Null
            Write-Host "#### Change Complete ####"
            Write-Host ""
        }
        else {
            Write-Host "$ServerName is already set"
                }        
    }
    foreach ($ESXiServer in $ESXiServers) {
    BloomFilter ($ESXiServer)
}

# Close vCenter connection
Disconnect-VIServer -Server $vCenterServer -Confirm:$False
