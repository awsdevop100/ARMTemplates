
$resourceGroupName = "Frontend-RG"
$NSGGroup = "FrontEnd-NSG"
$vnetwork = "bupavnet01"
$Subnet = "frontend1"
$VMNode0 = "BupafeNode0"
$VMNode1 = "BupafeNode1"

#Export NSG
Get-AzureRmNetworkSecurityGroup -Name webdeploy-NSG -ResourceGroupName $resourceGroupName | Get-AzureRmNetworkSecurityRuleConfig | Select * | Export-Csv -NoTypeInformation -Path .\FrontEnd-NSG.csv


#Update NSG
Update-AzureRMCustomNetworkSecurityGroup -CSVPath .\FrontEnd-NSG.csv   -ResourceGroupName $resourceGroupName -NetworkSecurityGroupName $NSGGroup

