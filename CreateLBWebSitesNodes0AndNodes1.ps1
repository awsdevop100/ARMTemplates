<#
 .SYNOPSIS
    Deploys a template to Azure

 .DESCRIPTION
    Deploys an Azure Resource Manager template

 .PARAMETER subscriptionId
    The subscription id where the template will be deployed.

 .PARAMETER resourceGroupName
    The resource group where the template will be deployed. Can be the name of an existing or a new resource group.

 .PARAMETER resourceGroupLocation
    Optional, a resource group location. If specified, will try to create a new resource group in this location. If not specified, assumes resource group is existing.

 .PARAMETER deploymentName
    The deployment name.

 .PARAMETER templateFilePath
    Optional, path to the template file. Defaults to template.json.

 .PARAMETER parametersFilePath
    Optional, path to the parameters file. Defaults to parameters.json. If file is not found, will prompt for parameter values based on template.
#>

param(


 [string]
 $resourceGroupLocation = "Northeurope",

 
 [string]
 $templateFilePath = "C:\bupa\ARMRepo\deploytemplate.json",

 [string]
 $parametersFilePath = "C:\bupa\ARMRepo\DeploymentParemeters.json"
)

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
 
cd C:\bupa\ARMRepo\

ls

#cd "C:\bupa\ARMRepo\deploytemplate.json"


$subscriptionId = 'xxxxxxxxxxxxxxxxxxxxx'  # Cloud
$subscriptionName = 'Visual Studio Premium with MSDN'   # Cloud

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

Remove-AzureRmVMExtension -ResourceGroupName "bupa-lb-webapp02-RG" -Name "IIS" -VMName "bupaNode0"
Remove-AzureRmVMExtension -ResourceGroupName "bupa-lb-webapp02-RG" -Name "IIS" -VMName "bupaNode1"


# Install IIS
Set-AzureRmVMExtension -ResourceGroupName "bupa-lb-webapp02-RG" `
    -ExtensionName "IIS" `
    -VMName "bupaNode0" `
    -Location "NorthEurope" `
    -Publisher Microsoft.Compute `
    -ExtensionType CustomScriptExtension `
    -TypeHandlerVersion 1.8 `
    -SettingString '{"commandToExecute":"powershell Install-WindowsFeature Web-Server, Web-Mgmt-Service, Web-Asp-Net45,NET-Framework-Features; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'


# Install IIS
Set-AzureRmVMExtension -ResourceGroupName "bupa-lb-webapp02-RG" `
    -ExtensionName "IIS" `
    -VMName "bupaNode1" `
    -Location "NorthEurope" `
    -Publisher Microsoft.Compute `
    -ExtensionType CustomScriptExtension `
    -TypeHandlerVersion 1.8 `
    -SettingString '{"commandToExecute":"powershell Install-WindowsFeature Web-Server, Web-Mgmt-Service, Web-Asp-Net45,NET-Framework-Features; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'


#---
#Associate NSG to a bupanic0

$nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName "bupa-lb-webapp02-RG" -Name "FrontEnd-NSG"

#Retrieve bupanic0 and store in variable:

#nic0
$nic = Get-AzureRmNetworkInterface -ResourceGroupName "bupa-lb-webapp02-RG" -Name "bupanic0"

#Set NetworkSecurityGroup property of NIC variable to NSG 

$nic.NetworkSecurityGroup = $nsg

#save  changes made to the NIC

Set-AzureRmNetworkInterface -NetworkInterface $nic

#---
#Associate NSG to a bupanic1

$nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName "bupa-lb-webapp02-RG" -Name "FrontEnd-NSG"

#Retrieve NIC and store it in a variable:

#nic1
$nic = Get-AzureRmNetworkInterface -ResourceGroupName "bupa-lb-webapp02-RG" -Name "bupanic1"

#Set NetworkSecurityGroup property of NIC variable to NSG 
$nic.NetworkSecurityGroup = $nsg

#save  changes made to the NIC
Set-AzureRmNetworkInterface -NetworkInterface $nic

$rule0 = New-AzureRmNetworkSecurityRuleConfig -Name Port_Any -Description "Port_Any" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix `
    Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange *

$rule1 = New-AzureRmNetworkSecurityRuleConfig -Name rdp-rule -Description "Allow RDP 3389" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 101 -SourceAddressPrefix `
    Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389

$rule2 = New-AzureRmNetworkSecurityRuleConfig -Name web-rule -Description "Allow 80" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 102 -SourceAddressPrefix `
    Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80

$rule2 = New-AzureRmNetworkSecurityRuleConfig -Name web-rule -Description "Allow 80" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 102 -SourceAddressPrefix `
    Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80

#Create New NSG
$nsg = new-AzureRmNetworkSecurityGroup -ResourceGroupName bupa-lb-webapp02-RG -Location northeurope -Name "FrontEnd-NSG" -SecurityRules $rule0, $rule1,$rule2


#Update NSG
Update-AzureRMCustomNetworkSecurityGroup -CSVPath "c:\temp\Frontend-NSG.csv" -ResourceGroupName "bupa-lb-webapp02-RG" -NetworkSecurityGroupName "FrontEnd-NSG"
