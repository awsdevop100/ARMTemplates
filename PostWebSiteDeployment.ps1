#Post Website Deployment

Remove-AzureRmVMExtension -ResourceGroupName "bupa-lb-webapp02-RG" -ExtensionName "IIS" -VMName "bupaNode0"
Remove-AzureRmVMExtension -ResourceGroupName "bupa-lb-webapp02-RG" -ExtensionName "AddComputerName" -VMName "bupaNode0"

 
#Update default.html
Set-AzureRmVMExtension -ResourceGroupName "bupa-lb-webapp02-RG" `
    -ExtensionName "AddComputerName" `
    -VMName "bupaNode0" `
    -Location "NorthEurope" `
    -Publisher Microsoft.Compute `
    -ExtensionType CustomScriptExtension `
    -TypeHandlerVersion 1.8 `
    -SettingString '{"commandToExecute":"powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'

#---
Remove-AzureRmVMExtension -ResourceGroupName "bupa-lb-webapp02-RG" -ExtensionName "IIS" -VMName "bupaNode1"
Remove-AzureRmVMExtension -ResourceGroupName "bupa-lb-webapp02-RG" -ExtensionName "AddComputerName" -VMName "bupaNode1"

 
#Update default.html
Set-AzureRmVMExtension -ResourceGroupName "bupa-lb-webapp02-RG" `
    -ExtensionName "AddComputerName" `
    -VMName "bupaNode1" `
    -Location "NorthEurope" `
    -Publisher Microsoft.Compute `
    -ExtensionType CustomScriptExtension `
    -TypeHandlerVersion 1.8 `
    -SettingString '{"commandToExecute":"powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'

