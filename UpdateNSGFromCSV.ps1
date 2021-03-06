﻿#VSTS Version


 
Param(
    [string]$nsgName = "FrontEnd-NSG",
    [string]$resourceGroup = "FrontEnd-RG",
    [string]$location = "northeurope",
    [string]$tagName = "bupa-nsg",
    [string]$tagValue = "Bupa-FrontEnd-NSG" 
)

write-host -ForegroundColor Green $tag
$r = [regex]"^(.*)\/(\d+)\.(\d+)\.(\d+)\.?(\d+)?.*$"
write-host -ForegroundColor Green $tag -match $r
write-host -ForegroundColor Green "source branch name" $env:BUILD_SOURCEBRANCHNAME 
write-host -ForegroundColor Green "commit id" $env:BUILD_SOURCEVERSION
write-host -ForegroundColor Green "build Path2" $env:BUILDPATH
write-host -ForegroundColor Green "DefinitionName" $env:BUILD_DEFINITIONNAME
write-host -ForegroundColor Green "Sources Directory" $env:BUILD_SOURCESDIRECTORY
write-host -ForegroundColor Green "Staging Directory" $env:BUILD_STAGINGDIRECTORY
write-host -ForegroundColor Green "Default Working Directory" $env:SYSTEM_DEFAULTWORKINGDIRECTORY
write-host -ForegroundColor Green "Binaries Directory" $env:BUILD_BINARIESDIRECTORY 

$date = $(get-date -f yyyy-MM-dd-HH-mm)


$Before = "$buildsourceDirectory\ARMTemplates-master\BeforeFrontEnd-NSG.csv"
Test-Path $Before
Write-host -ForegroundColor Green "Before File:|"  $Before


$customCsv = "$buildsourceDirectory\ARMTemplates-master\AfterFrontEnd-NSG.csv"
Test-Path $customCsv
Write-host -ForegroundColor Green  "After File:" $customCsv


#BackupBeforeUpdate  - Export NSG
#Get-AzureRmNetworkSecurityGroup -Name FrontEnd-NSG -ResourceGroupName FrontEnd-RG | Get-AzureRmNetworkSecurityRuleConfig | Select * | Export-Csv -NoTypeInformation -Path $Before

#Copy-Item -Path ".\Backup\FrontEnd-NSG.csv" -Destination ".\Backup\FrontEnd-NSG-$date.csv"

ls



Compare-Object -ReferenceObject $before -DifferenceObject  $customCsv
if (diff $before $customCsv) {
   write-host 'not equal, updating NSG'
   #Update NSG
#rules array
$rulesArray = @()
 

#add custom rules
Write-Verbose 'Importing custom CSV'
$customRules = Import-Csv $customCsv
 
foreach ($customRule in $customRules) {
    $customNsgRule = New-AzureRmNetworkSecurityRuleConfig `
        -Name $customRule.Name `
        -Description $customRule.description `
        -Protocol $customRule.protocol `
        -SourcePortRange $customRule.sourcePortRange `
        -DestinationPortRange $customRule.destinationPortRange `
        -SourceAddressPrefix $customRule.sourceAddressPrefix `
        -DestinationAddressPrefix $customRule.destinationAddressPrefix `
        -Access $customRule.access `
        -Priority $customRule.priority `
        -Direction $customRule.direction
 
    $rulesArray += $customNsgRule
}

 
#create NSG
Write-Verbose 'creating nsg'
New-AzureRmNetworkSecurityGroup -Name $nsgName -ResourceGroupName $resourceGroup `
    -Location $location `
    -Tag @{Name=$tagName;Value=$tagValue} `
    -SecurityRules $rulesArray `
    -Force
}
