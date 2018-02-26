$subscriptionId = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxx'  # Cloud
$subscriptionName = 'Visual Studio Premium with MSDN'   # Cloud
#$TenantID = '0448d8b2-0625-41f7-9062-953db800ee20'

$resourceGroupName = 'bupa-lb-webapp02-RG'
write-host -foreground green $resourceGroupName


#Login-AzureRmAccount
 Write-Host "Selecting subscription '$subscriptionId'";
 Get-AzureRmContext
 Set-AzureRmContext -SubscriptionId $subscriptionId  
 # select subscription
 Write-Host "Selecting subscription '$subscriptionId'";
 Select-AzureRmSubscription -SubscriptionName  $SubscriptionName
 Select-AzureRmSubscription -SubscriptionID $subscriptionId;
 Get-AzureRmSubscription -SubscriptionName  $SubscriptionName

# select subscription
Write-Host -ForegroundColor Green  "Selecting subscription '$subscriptionId'";



#Stop VMs
Function StopVM()
{
$powerstateMask = ‘PowerState/*’
$powerstateStopped = ‘PowerState/stopped’
$powerstateDealloc = ‘PowerState/deallocated’

$servers = ('BupaNode0', 'BupaNode1', 'BupaNode2', 'BupaNode3', 'BupaNode4')
foreach ($server in $servers) 
  {
$VM = (Get-AzureRmVM -Name $server -ResourceGroupName $resourceGroupName -Status | Stop-AzureRmVM -force ) 
       Write-Verbose “Going to deallocate the VM (this might take a minute)…”

if(!$VM) { Write-Error “VM ‘$resourceGroupName’ does not exist.” }
else
  {
$vmState = ($VM.Statuses | Where Code -Like $powerstateMask)[0]
Write-Output (“Current PowerState of VM is ‘{0}'” -f $vmState.DisplayStatus)
if($vmState.Code -eq $powerstateStopped)
  {
# Note: Deallocation via Stop-AzureRmVM is blocking (might take 1-2 minutes)
Write-Verbose “Going to deallocate the VM (this might take a minute)…”
Stop-AzureRmVM -Name $server -ResourceGroupName $resourceGroupName -Force
Write-Verbose “Done!”
  }
else { Write-Verbose “All is fine!” }
  }
 }
}

StopVM