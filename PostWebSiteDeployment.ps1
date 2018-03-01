resourceGroupName = "Frontend-RG"
$NSGGroup = "FrontEnd-NSG"
$vnetwork = "bupavnet01"
$Subnet = "frontend1"
$VMNode0 = "BupafeNode0"
$VMNode1 = "BupafeNode1"


Remove-AzureRmVMExtension -ResourceGroupName $resourceGroupName -Name "IIS" -VMName  $VMNode0 -force
Remove-AzureRmVMExtension -ResourceGroupName $resourceGroupName -Name "IIS" -VMName  $VMNode1 -force


# Install IIS
Set-AzureRmVMExtension -ResourceGroupName "$resourceGroupName" `
    -ExtensionName "IIS" `
    -VMName $VMNode0 `
    -Location "NorthEurope" `
    -Publisher Microsoft.Compute `
    -ExtensionType CustomScriptExtension `
    -TypeHandlerVersion 1.8 `
    -SettingString '{"commandToExecute":"powershell Install-WindowsFeature Web-Server, Web-Mgmt-Service, Web-Mgmt-Console, Web-Mgmt-Compat, Web-Asp-Net45, Web-App-Dev, NET-Framework-Features; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Node.htm\" -Value $($env:computername)"}'


# Install IIS
Set-AzureRmVMExtension -ResourceGroupName "$resourceGroupName" `
    -ExtensionName "IIS" `
    -VMName $VMNode1 `
    -Location "NorthEurope" `
    -Publisher Microsoft.Compute `
    -ExtensionType CustomScriptExtension `
    -TypeHandlerVersion 1.8 `
    -SettingString '{"commandToExecute":"powershell Install-WindowsFeature Web-Server, Web-Mgmt-Service, Web-Mgmt-Console, Web-Mgmt-Compat, Web-Asp-Net45, Web-App-Dev, NET-Framework-Features; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Node.htm\" -Value $($env:computername)"}'

Remove-AzureRmVMExtension -ResourceGroupName $resourceGroupName -Name "IIS" -VMName  $VMNode0 -force
Remove-AzureRmVMExtension -ResourceGroupName $resourceGroupName -Name "IIS" -VMName  $VMNode1 -force

    
    #Default.htm - $VMNode0
Set-AzureRmVMExtension -ResourceGroupName "$resourceGroupName" `
    -ExtensionName "IIS" `
    -VMName $VMNode0 `
    -Location "NorthEurope" `
    -Publisher Microsoft.Compute `
    -ExtensionType CustomScriptExtension `
    -TypeHandlerVersion 1.8 `
        -SettingString '{"commandToExecute":"powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Node.html\" -Value $($env:computername)"}'


#Default.htm - $VMNode1
Set-AzureRmVMExtension -ResourceGroupName "$resourceGroupName" `
    -ExtensionName "IIS" `
    -VMName $VMNode1 `
    -Location "NorthEurope" `
    -Publisher Microsoft.Compute `
    -ExtensionType CustomScriptExtension `
    -TypeHandlerVersion 1.8 `
        -SettingString '{"commandToExecute":"powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Node.html\" -Value $($env:computername)"}'

