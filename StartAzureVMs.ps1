$resourceGroupName = "Frontend-RG"
$NSGGroup = "FrontEnd-NSG"
$vnetwork = "bupavnet01"
$Subnet = "frontend1"
$VMNode0 = "BupafeNode0"
$VMNode1 = "BupafeNode1"
#Connect-AzureRmAccount
write-host -foreground green $resourceGroupName


#Stop VMs
Function StartVM()
{
$powerstateMask = ‘PowerState/*’
$powerstateStopped = ‘PowerState/stopped’
$powerstateDealloc = ‘PowerState/deallocated’

$servers = ('BupafeNode0', 'BupafeNode1')
foreach ($server in $servers) 
  {
$VM = (Get-AzureRmVM -Name $server -ResourceGroupName $resourceGroupName -Status | Start-AzureRmVm ) 
       Write-Verbose “Starting VM $VM (this might take a minute)…”

if(!$VM) { Write-Error “VM ‘$vm’ does not exist.” }
else
  {
if($vmState = $powerstateMask ) 
{ Write-Error “VM ‘$VM’ Has Stopped.” }
$vmState = ($VM.Statuses | Where Code -Like $powerstateMask)[0]
Write-Output (“Current PowerState of VM $VM is ‘{0}'” -f $vmState.DisplayStatus)
if($vmState.Code -eq $powerstateStopped)
  {
# Note: Deallocation via Stop-AzureRmVM is blocking (might take 1-2 minutes)
Write-Verbose “Going to deallocate the VM (this might take a minute)…”
#Stop-AzureRmVM -Name $server -ResourceGroupName $resourceGroupName -Force
Write-Verbose “Done!”
  }
else { Write-Verbose “All is fine!” }
  }
 }
}

StartVM
