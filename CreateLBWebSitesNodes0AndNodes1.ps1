
param(


 [string]
 $resourceGroupLocation = "Northeurope",

 [string]
 $resourceGroupName = "FrontEnd-RG",

 [string]
 $vnetwork = "bupavnet01",

 [string]
 $Subnet = "frontend1", 

 [string]
 $NSGGroup = "FrontEnd-NSG", 

 [string]
 $VMNode0 = "bupafenode0", 

  [string]
 $VMNode1 = "bupafenode1", 


  [string]
 $templateFilePath = ".\deploytemplate.json",

 [string]
 $parametersFilePath = ".\DeploymentParemeters.json"



)


# $resourceGroupName = "bupa-lb-webapp02-RG",

<#
.SYNOPSIS
    Registers RPs
#>
Function RegisterRP {
    Param(
        [string]$ResourceProviderNamespace
    )

    Write-Host "Registering resource provider '$ResourceProviderNamespace'";
    Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace;
}

#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"

#cd C:\BUPAWEBAPP\ARMTemplates-master

ls


#$subscriptionId = Connect-AzureRmAccount

write-host -foreground green $resourceGroupName



# selected subscription
$subscriptionId

# Register RPs
$resourceProviders = @("microsoft.insights","microsoft.web");
if($resourceProviders.length) {
    Write-Host "Registering resource providers"
    foreach($resourceProvider in $resourceProviders) {
        RegisterRP($resourceProvider);
    }
}


#test-path $resourceGroupName
Get-AzureRmResourceGroup -Name $ResourceGroupName -ev notPresent -ea 0  

if ($notPresent)
{
    Write-Host -ForegroundColor Red "ResourceGroup doesn't exist"
    Write-Host -ForegroundColor Red "Creating ResourceGroup"
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation

}
else
{
    Write-Host -ForegroundColor Red "ResourceGroup already exist"
}




# Start the deployment
Write-Host "Starting deployment...";
if(Test-Path $parametersFilePath) {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath -Verbose -Debug;
} else {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -Verbose -Debug;
    }

Remove-AzureRmVMExtension -ResourceGroupName $resourceGroupName -Name "IIS" -VMName  $VMNode0
Remove-AzureRmVMExtension -ResourceGroupName $resourceGroupName -Name "IIS" -VMName  $VMNode1


# Install IIS
Set-AzureRmVMExtension -ResourceGroupName "$resourceGroupName" `
    -ExtensionName "IIS" `
    -VMName $VMNode0 `
    -Location "NorthEurope" `
    -Publisher Microsoft.Compute `
    -ExtensionType CustomScriptExtension `
    -TypeHandlerVersion 1.8 `
    -SettingString '{"commandToExecute":"powershell Install-WindowsFeature Web-Server, Web-Mgmt-Service, Web-Asp-Net45,NET-Framework-Features; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'


# Install IIS
Set-AzureRmVMExtension -ResourceGroupName "$resourceGroupName" `
    -ExtensionName "IIS" `
    -VMName $VMNode1 `
    -Location "NorthEurope" `
    -Publisher Microsoft.Compute `
    -ExtensionType CustomScriptExtension `
    -TypeHandlerVersion 1.8 `
    -SettingString '{"commandToExecute":"powershell Install-WindowsFeature Web-Server, Web-Mgmt-Service, Web-Asp-Net45,NET-Framework-Features; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'


$rule0 = New-AzureRmNetworkSecurityRuleConfig -Name Allow-8172 -Description "Allow 8172" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 102 -SourceAddressPrefix `
    Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange *


$rule1 = New-AzureRmNetworkSecurityRuleConfig -Name Allow-8080 -Description "Allow 8080" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 103 -SourceAddressPrefix `
    Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange *

$rule2 = New-AzureRmNetworkSecurityRuleConfig -Name Allow-443 -Description "Allow 443" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 104 -SourceAddressPrefix `
    Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange *

$rule3 = New-AzureRmNetworkSecurityRuleConfig -Name Allow-80 -Description "Allow 80" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 105 -SourceAddressPrefix `
    Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange *



#---
#Create New NSG
$nsg = new-AzureRmNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location northeurope -Name $NSGGroup -SecurityRules $rule0,  $rule1,  $rule2,  $rule3


#Associate NSG to Subnet
#Get NSG 
$nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $resourceGroupName  -Name $NSGGroup
#Select VNET
$vnetName = (Get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName).Name 
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName
 
# Select Subnet 
$subnetName = $vnet.Subnets.Name 
$subnet = $vnet.Subnets | Where-Object Name -eq $subnetName
 
# Associate NSG to subnet
Set-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnetName -AddressPrefix $subnet.AddressPrefix -NetworkSecurityGroup $nsg | Set-AzureRmVirtualNetwork

#---


#---
#Associate NSG to a bupanic0
#$nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName "$resourceGroupName" -Name "FrontEnd-NSG"

#Retrieve bupanic0 and store in variable:
#nic0
#$nic = Get-AzureRmNetworkInterface -ResourceGroupName "$resourceGroupName" -Name "bupanic0"

#Set NetworkSecurityGroup property of NIC variable to NSG 
#$nic.NetworkSecurityGroup = $nsg

#save  changes made to the NIC
#Set-AzureRmNetworkInterface -NetworkInterface $nic

#---
#Associate NSG to a bupanic1
#$nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName "$resourceGroupName" -Name "FrontEnd-NSG"

#Retrieve NIC and store it in a variable:
#nic1
#$nic = Get-AzureRmNetworkInterface -ResourceGroupName "$resourceGroupName" -Name "bupanic1"

#Set NetworkSecurityGroup property of NIC variable to NSG 
#$nic.NetworkSecurityGroup = $nsg


#save  changes made to the NIC
#Set-AzureRmNetworkInterface -NetworkInterface $nic


