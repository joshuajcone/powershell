# Set variables to indicate value and key to set
# This Addresses CTX135299 - https://support.citrix.com/article/CTX135299/setting-vdisk-boot-menu-as-a-default-option
$RegistryPath = 'HKLM:\Software\Citrix\ProvisioningServices\StreamProcess\'
$Name         = 'SkipBootMenu'
$Value        = '1'
# Create the key if it does not exist
If (-NOT (Test-Path $RegistryPath)) {
  New-Item -Path $RegistryPath -Force | Out-Null
}  
# Now set the value
New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD -Force
