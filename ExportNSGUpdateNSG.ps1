
cd C:\bupa\ARMRepo

#Export NSG
Get-AzureRmNetworkSecurityGroup -Name webdeploy-NSG -ResourceGroupName bupa-lb-webapp02-RG | Get-AzureRmNetworkSecurityRuleConfig | Select * | Export-Csv -NoTypeInformation -Path .\FrontEnd-NSG.csv


#Update NSG
Update-AzureRMCustomNetworkSecurityGroup -CSVPath .\FrontEnd-NSG.csv   -ResourceGroupName bupa-lb-webapp02-RG -NetworkSecurityGroupName "FrontEnd-NSG"

