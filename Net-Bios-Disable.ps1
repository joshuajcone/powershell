# Set variables to indicate value and key to set
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces\Tc*\'
$Name         = 'NetbiosOptions'
$Value        = '2'
foreach ($Key in (Get-ItemProperty -Exclude *C7568B63* -path $RegistryPath).$Name)
{
    if ($Key -match $Value)
    { Write-Output "Property already exist"
    }
    else {Set-ItemProperty -Exclude *C7568B63* -Path $RegistryPath -Name $Name -Value $Value
    Write-Output "Value has been changed"
    }
}
