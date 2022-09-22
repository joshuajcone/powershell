#Assign tag on VM that matches the home ESXi hostname

$vCenterServer = "Your vCenter Name"
$cluster_name = "Your Cluster Name"
$tag_category = "The category of the tag"
$sendTo = "sendtoAddress@sterilized.com"
$From = "vCenter@sterilized.com"
$Smtp = "smtp-relay.sterilized.com"

#Connect to vCenterServer
Connect-VIServer -Server $vCenterServer | Out-Null

#Get The VM's in the Cluster
$VMs = Get-Cluster $cluster_name | Get-VM | Where-Object {$_.PowerState -eq 'PoweredOn'}

#Loop for VM's
foreach($VM in $VMs)
   {
    #Get the ESXi hostname of the VM
    $esxHost = Get-VMHost -VM $VM

    #Get the VM Tags 
    $VMTag = (Get-TagAssignment -Entity $vm -Category $tag_category).Tag.Name

    #Check to see if the assigned VMTag is Null
    if ($null -eq $VMTag) {

        #Output stating the VM needs to have the assigned tag. Uncomment next line for this local console dispaly
        #Write-Output "$VM does not have tag assigned"

        #Email alert if a VM in the cluster doesn't have a tag assigned
        $MailString = "VM $VM Does not have a tag assigned, it currently lives on $esxHost."
        Send-MailMessage -From $From -To $sendTo -Subject "EPICODB-VM $VM No Tag Assigned" -SmtpServer $Smtp -Body $MailString
   
   }
   #Check to see if the assigned VMTag matches the ESXi hostname
   Elseif ($VMTag -notlike $esxHost) {

        #Output stating the VM needs to move to the assigned tag. Uncomment next line for this local console dispaly
        #Write-Output "$VM needs to move to $VMTag"

        #Output the VMname in the wrong location to email.
        $MailString = "VM $VM is on the wrong host, it needs to move to $VMTag."
        Send-MailMessage -From $From -To $sendTo -Subject "EPICODB-VM $VM Not Home" -SmtpServer $Smtp -Body $MailString
   } 
}
