#VSTS Version


 
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

copy-item $env:BUILD_SOURCESDIRECTORY\*.* $env:BUILD_STAGINGDIRECTORY

$Before = "$buildsourceDirectory\ARMTemplates-master\BeforeFrontEnd-NSG.csv"
Test-Path $Before
Write-host -ForegroundColor Green "Before File:"  $Before


$customCsv = "$buildsourceDirectory\ARMTemplates-master\AfterFrontEnd-NSG.csv"
Test-Path $customCsv
Write-host -ForegroundColor Green  "After File:" $customCsv


write-host "Source Directory: "-ForegroundColor Green  $env:BUILD_SOURCESDIRECTORY

write-host "Staging Directory: "-ForegroundColor Green  $env:BUILD_STAGINGDIRECTORY

write-host "Default Working Directory: "-ForegroundColor Green  $env:SYSTEM_DEFAULTWORKINGDIRECTORY
$env:SYSTEM_DEFAULTWORKINGDIRECTORY
ls

$env:BUILD_STAGINGDIRECTORY
ls

write-host "customCsv: "-ForegroundColor Green  $customCsv

write-host "customRules: "-ForegroundColor Green  $customRules

write-host "Network Security Group: "-ForegroundColor Green  $nsgName

write-host "Resource Group: "-ForegroundColor Green  $resourceGroup

Get-AzureRmNetworkSecurityGroup -Name $nsgName -ResourceGroupName $resourceGroup 


Compare-Object -ReferenceObject $before -DifferenceObject  $customCsv
if (diff $before $customCsv) {
   write-host 'The csv files are not equal, updating NSG' $nsgName
   #Update NSG
   
$customCsv = "$buildsourceDirectory\ARMTemplates-master\AfterFrontEnd-NSG.csv"


#rules array
$rulesArray = @()
 

#add custom rules
Write-Verbose 'Importing custom CSV'
$customCsv = "$buildsourceDirectory\ARMTemplates-master\AfterFrontEnd-NSG.csv"
write-host "Source Directory: "-ForegroundColor Green  $env:BUILD_SOURCESDIRECTORY

write-host "Staging Directory: "-ForegroundColor Green  $env:BUILD_STAGINGDIRECTORY

write-host "Default Working Directory: "-ForegroundColor Green  $env:SYSTEM_DEFAULTWORKINGDIRECTORY
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

$getAzureRmNetworkSecurityGroup = get-AzureRmNetworkSecurityGroup -Name $nsgName -ResourceGroupName $resourceGroup
 
$getAzureRmNetworkSecurityGroup

#create NSG
Write-Verbose 'creating nsg' $nsgName
New-AzureRmNetworkSecurityGroup -Name $nsgName -ResourceGroupName $resourceGroup `
    -Location $location `
    -Tag @{Name=$tagName;Value=$tagValue} `
    -SecurityRules $rulesArray `
    -Force
}


