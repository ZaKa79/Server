# Forbinder til Azure
Connect-AzAccount

"""---------------------------------------"""

# Opret en ny ResourceGoup
New-AzResourceGroup -Location NorthEurope -Name server2b

# Lav en Vm
New-AzVm -ResourceGroupName 'server2b' -Name 'Prod' -Location 'NorthEurope'`
-Image UbuntuLTS `
-size Standard_B2s `

# Lav endnu en Vm
New-AzVm -ResourceGroupName 'server2b' -Name 'Dev' -Location 'WestEurope'`
-Image Debian `
-size Standard_B2s `

# Stop (deallocate) the VM
Stop-AzVM -ResourceGroupName "server2b" -Name "Dev" -Force

# Lav Vm nummer tre
New-AzVm -ResourceGroupName 'server2b' -Name 'ProdWebserver' -Location 'NorthEurope'`

"""---------------------------------------"""

# 1.	List all the Virtual Machine names in Azure within a given resource group(say server2x) whose name starts with "prod" and ends with "webserver".
Get-AzVM -ResourceGroupName server2b | Where-Object {$_.Name -like 'prod*webserver'} | Select-Object Name

# 2. List Virtual Machines within northeurope or westeurope location.
Get-AzVM -ResourceGroupName server2b | Where-Object {($_.Location -eq 'northeurope') -or ($_.Location -eq 'westeurope')} | Select-Object Name

# 3. List all Virtual Machine that are in deallocated state. Display only VM name and PowerState
Get-AzVM -ResourceGroupName server2b -Status | Where-Object {$_.PowerState -eq 'VM deallocated'} | Select-Object Name, PowerState

# Start (Running) the VM
Start-AzVM -ResourceGroupName "server2b" -Name "Dev" 

# 4. List Virtual Machines that are either in running state and VM are in westeurope location.
Get-AzVM -ResourceGroupName server2b -Status | Where-Object {$_.PowerState -eq 'VM running' -and $_.Location -eq 'westeurope'} | Select-Object Name, Location, PowerState

# 5. List Virtual Machines that are NOT in westeurope region.
Get-AzVM -ResourceGroupName server2b -Status | Where-Object {$_.Location -ne 'westeurope'} | Select-Object Name, Location

# 6. List all Virtual Machines with their OS. Display only VM name and OSType.
Get-AzVM -ResourceGroupName server2b | Select-Object Name, @{Name="OSType"; Expression={$_.StorageProfile.OSDisk.OSType}} 

# 7. List all Virtual Machines that has Linux OS
Get-AzVM -ResourceGroupName server2b -Status | Where-Object {$_.StorageProfile.OsDisk.OsType -eq 'Linux'} | Select-Object Name

# 8. List all VMs with their VM Size.
Get-AzVM | Select-Object Name, @{Name="VM Size"; Expression={$_.HardwareProfile.VmSize}}

# 9. List all Virtual Machines that are in D series of VM size
Get-AzVM | Where-Object {$_.HardwareProfile.VmSize -like "Standard_D*"} | Select-Object Name, @{Name="VM Size"; Expression={$_.HardwareProfile.VmSize}}

# 10. List all Virtual Machines that are of D series VM size and resource group name contains word '2b'
# Note: Output should be a table with only 3 columns : VM Name, VM Size, VM OS
Get-AzVM | Where-Object {$_.HardwareProfile.VmSize -like "Standard_D*" -and $_.ResourceGroupName -like "*2b*"} | Select-Object Name, @{Name="VMSize"; Expression={$_.HardwareProfile.VmSize}}, @{Name="VM OS"; Expression={$_.StorageProfile.OsDisk.OsType}}

# 11. List all Virtual Machine that satisfy below conditions
# Status : stopped
# Region : westeurope
# Resource Group : Server2b
# OS : Linux (any version)
# Note: In output, display only VM name, ProvisioningState, VMSize and OSType
Get-AzVM -ResourceGroupName server2b -Status | Where-Object {$_.PowerState -eq 'VM deallocated' -and $_.Location -eq "westeurope" -and $_.StorageProfile.OsDisk.OsType -eq 'Linux'} | Select-Object Name, PowerState, @{Name="VM Size"; Expression={$_.HardwareProfile.VmSize}}, @{Name="OSType"; Expression={$_.StorageProfile.OSDisk.OSType}}

#Slet ResourceGroup
Remove-AzResourceGroup 'server2b'